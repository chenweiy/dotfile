#!/usr/bin/python

import argparse
import ctypes
import os
# import sys
# import copy
# import math

this_path = os.path.dirname(os.path.realpath(__file__))

assert(0==os.system('cd "%s" && make spiffs_.so' % this_path))

spiffs_lib = ctypes.CDLL(os.path.join(this_path,'spiffs_.so'))

error_tab = { 0:"SPIFFS_OK",
              -10000:"SPIFFS_ERR_NOT_MOUNTED",
              -10001:"SPIFFS_ERR_FULL",
              -10002:"SPIFFS_ERR_NOT_FOUND",
              -10003:"SPIFFS_ERR_END_OF_OBJECT",
              -10004:"SPIFFS_ERR_DELETED",
              -10005:"SPIFFS_ERR_NOT_FINALIZED",
              -10006:"SPIFFS_ERR_NOT_INDEX",
              -10007:"SPIFFS_ERR_OUT_OF_FILE_DESCS",
              -10008:"SPIFFS_ERR_FILE_CLOSED",
              -10009:"SPIFFS_ERR_FILE_DELETED",
              -10010:"SPIFFS_ERR_BAD_DESCRIPTOR",
              -10011:"SPIFFS_ERR_IS_INDEX",
              -10012:"SPIFFS_ERR_IS_FREE",
              -10013:"SPIFFS_ERR_INDEX_SPAN_MISMATCH",
              -10014:"SPIFFS_ERR_DATA_SPAN_MISMATCH",
              -10015:"SPIFFS_ERR_INDEX_REF_FREE",
              -10016:"SPIFFS_ERR_INDEX_REF_LU",
              -10017:"SPIFFS_ERR_INDEX_REF_INVALID",
              -10018:"SPIFFS_ERR_INDEX_FREE",
              -10019:"SPIFFS_ERR_INDEX_LU",
              -10020:"SPIFFS_ERR_INDEX_INVALID",
              -10021:"SPIFFS_ERR_NOT_WRITABLE",
              -10022:"SPIFFS_ERR_NOT_READABLE",
              -10023:"SPIFFS_ERR_CONFLICTING_NAME",
              -10024:"SPIFFS_ERR_NOT_CONFIGURED",

              -10025:"SPIFFS_ERR_NOT_A_FS",
              -10026:"SPIFFS_ERR_MOUNTED",
              -10027:"SPIFFS_ERR_ERASE_FAIL",
              -10028:"SPIFFS_ERR_MAGIC_NOT_POSSIBLE",

              -10029:"SPIFFS_ERR_NO_DELETED_BLOCKS",

              -10030:"SPIFFS_ERR_FILE_EXISTS",

              -10031:"SPIFFS_ERR_NOT_A_FILE",
              -10032:"SPIFFS_ERR_RO_NOT_IMPL",
              -10033:"SPIFFS_ERR_RO_ABORTED_OPERATION",
              -10034:"SPIFFS_ERR_PROBE_TOO_FEW_BLOCKS",
              -10035:"SPIFFS_ERR_PROBE_NOT_A_FS",
              -10036:"SPIFFS_ERR_NAME_TOO_LONG",

              -10037:"SPIFFS_ERR_IX_MAP_UNMAPPED",
              -10038:"SPIFFS_ERR_IX_MAP_MAPPED",
              -10039:"SPIFFS_ERR_IX_MAP_BAD_RANGE",

              -10040:"SPIFFS_ERR_SEEK_BOUNDS",
              -10050:"SPIFFS_ERR_INTERNAL",

              -10100:"SPIFFS_ERR_TEST"}

def spiffs_error(code):
    try:
        return error_tab[code]
    except KeyError:
        return "unknown error %d"%code

SPIFFS_O_APPEND  = SPIFFS_APPEND = (1<<0)
SPIFFS_O_TRUNC   = SPIFFS_TRUNC  = (1<<1)
SPIFFS_O_CREAT   = SPIFFS_CREAT  = (1<<2)
SPIFFS_O_RDONLY  = SPIFFS_RDONLY = (1<<3)
SPIFFS_O_WRONLY  = SPIFFS_WRONLY = (1<<4)
SPIFFS_O_RDWR    = SPIFFS_RDWR   = (SPIFFS_RDONLY | SPIFFS_WRONLY)
SPIFFS_O_DIRECT  = SPIFFS_DIRECT = (1<<5)
SPIFFS_O_EXCL    = SPIFFS_EXCL   = (1<<6)

SPIFFS_SEEK_SET = 0
SPIFFS_SEEK_CUR = 1
SPIFFS_SEEK_END = 2

class SpiffsException(Exception):
    def __str__(self):
        errno = self.args[0]
        return "%d (%s)"%(errno, spiffs_error(errno))

class Spiffs(object):
    def __init__(self,
                 phys_size,
                 phys_addr,
                 phys_erase_block,
                 log_page_size,
                 log_block_size):

        self.phys_size = phys_size
        self.phys_addr = phys_addr
        self.phys_erase_block = phys_erase_block
        self.log_page_size = log_page_size
        self.log_block_size = log_block_size

        self.mount()

    def mount(self):

        RWCallback = ctypes.CFUNCTYPE(ctypes.c_int32,
                                      ctypes.c_uint32, #addr
                                      ctypes.c_uint32, #size
                                      ctypes.POINTER(ctypes.c_uint8), # data
        )

        EraseCallback = ctypes.CFUNCTYPE(ctypes.c_int32,
                                         ctypes.c_uint32, #addr
                                         ctypes.c_uint32, #size
        )

        # hold a reference, otherwise garbage-collection crash
        self._rcb = RWCallback(self._on_read)
        self._wcb = RWCallback(self._on_write)
        self._ecb = EraseCallback(self._on_erase)

        spiffs_lib.mk_spiffs_mount.restype = ctypes.c_void_p

        fs = spiffs_lib.mk_spiffs_mount(self.phys_size,
                                        self.phys_addr,
                                        self.phys_erase_block,
                                        self.log_page_size,
                                        self.log_block_size,
                                        self._rcb,
                                        self._wcb,
                                        self._ecb)
        if fs == None:
            print("error mount")
            raise SpiffsException(fs)


        self.fs = ctypes.c_void_p(fs)

    def unmount(self):
        res = spiffs_lib.mk_spiffs_umount(self.fs)
        if res<0: raise SpiffsException(res)
        self.fs = None

    def _error_print_traceback(f):
        def ret(self, *args):
            try:
                return f(self, *args)
            except:
                import traceback
                traceback.print_exc()
                return -1
        return ret

    @_error_print_traceback
    def _on_read(self, addr, size, dst):
        "Extra layer of indirection to unwrap the ctypes stuff"
        #print "on_read",addr,size
        data = self.on_read(int(addr), int(size))
        for i in range(size):
            dst[i] = ord(data[i])
        return 0

    @_error_print_traceback
    def _on_write(self, addr, size, src):
        #print "on_write",addr,size
        data = [chr(src[i]) for i in range(size)]
        self.on_write(addr, data)
        return 0

    @_error_print_traceback
    def _on_erase(self, addr, size):
        #print "on_erase",addr,size
        self.on_erase(addr, size)
        return 0

    ##############################################
    # Backend interface

    def on_read(self, addr, size):
        "Subclass me!"
        print("base on_read",addr,size)
        return '\xff'*size

    def on_write(self, addr, data):
        "Subclass me!"
        print("base on_write",addr,len(data))

    def on_erase(self, addr, size):
        "Subclass me!"
        print("base on_erase",addr,size)

    ##############################################
    # API wrap

    def fopen(self, filename, flags):
        res = spiffs_lib.SPIFFS_open(self.fs, filename, flags, 0)
        if res<0: raise SpiffsException(res)
        return res

    def fwrite(self, fd, data):
        res = spiffs_lib.SPIFFS_write(self.fs, fd, data, len(data))
        if res != len(data): raise SpiffsException(res)
        return res

    def fread(self, fd, count=1):
        buf = (ctypes.c_uint8 * count)()
        res = spiffs_lib.SPIFFS_read(self.fs, fd, buf, count)
        if res<0: raise SpiffsException(res)
        ret = [chr(c) for c in buf][:res]
        return ret

    def fclose(self, fd):
        res = spiffs_lib.SPIFFS_close(self.fs, fd)
        if res<0: raise SpiffsException(res)

    def dir(self):
        entries=[]
        def collect_entry(name, size, dentry_id):
            entries.append([str(name), int(size), int(dentry_id)])

        EntryCallback = ctypes.CFUNCTYPE(None,
                                         ctypes.c_char_p,
                                         ctypes.c_uint32, #size
                                         ctypes.c_uint32 #id)
        )
        entry_cb = EntryCallback(collect_entry)

        res = spiffs_lib.mk_dir(self.fs, entry_cb)

        if res: raise SpiffsException(res)

        return entries

    def fseek(self, fd, offset, whence = SPIFFS_SEEK_SET):
        res = spiffs_lib.SPIFFS_lseek(self.fs, fd, offset, whence)
        if res<0: raise SpiffsException(res)
        return res

    def ftell(self, fd):
        res = spiffs_lib.SPIFFS_tell(self.fs, fd)
        if res<0: raise SpiffsException(res)
        return res

    def remove(self, path):
        res = spiffs_lib.SPIFFS_remove(self.fs, path)
        if res<0: raise SpiffsException(res)

    ##############################################
    # Pythonic API

    def open(self, filename, mode=None):
        mode = mode or 'r'

        mode = ''.join(mode.split('b'))

        spiffs_mode = {'r':SPIFFS_RDONLY,
                       'r+':SPIFFS_RDWR,
                       'w':SPIFFS_WRONLY | SPIFFS_TRUNC | SPIFFS_CREAT,
                       'w+':SPIFFS_RDWR | SPIFFS_TRUNC | SPIFFS_CREAT,
                       'a':SPIFFS_WRONLY,
                       'a+':SPIFFS_RDWR}[mode]

        fd = self.fopen(filename, spiffs_mode)

        if fd<0: raise SpiffsException(fd)

        if mode.startswith('a'):
            self.fseek(fd, 0, SPIFFS_SEEK_END)

        return SpiffsFile(self, fd)

class SpiffsFile(object):
    "A Python file-like interface"
    def __init__(self, parent, fd):
        self.parent = parent
        self.fd = fd
    def __enter__(self):
        return self
    def __exit__(self, exc_type, exc_val, exc_tb):
        self.close()

    def read(self, count=-1):
        if count < 1:
            pos = self.tell()
            size = self.seek(0, SPIFFS_SEEK_END)
            self.seek(pos)
            count = size-pos
        return ''.join(self.parent.fread(self.fd, count))

    def write(self, *args, **kwargs):
        return self.parent.fwrite(self.fd, *args, **kwargs)
    def close(self, *args, **kwargs):
        return self.parent.fclose(self.fd, *args, **kwargs)
    def seek(self, *args, **kwargs):
        return self.parent.fseek(self.fd, *args, **kwargs)
    def tell(self, *args, **kwargs):
        return self.parent.ftell(self.fd, *args, **kwargs)

class SpiffsCharsBack(Spiffs):
    "list-of-chars as block device"
    def __init__(self, chars, phys_addr, blocksize, 
            pagesize, *args, **kwargs):
        self.chars = chars
        super(SpiffsCharsBack, self).__init__(len(chars), #phys_size
                phys_addr, 
                blocksize, #phys_erase_block
                pagesize, #log_page_size
                blocksize,#log_block_size
                *args, **kwargs)

    def on_read(self, addr, size):
        return ''.join(self.chars[addr:addr+size])

    def on_write(self, addr, data):
        was_data = self.chars[addr:addr+len(data)]
        is_data = []

        for was,new in zip(was_data,data):
            now = ord(was) & ord(new)
            is_data.append(chr(now))

        self.chars[addr:addr+len(data)] = is_data

    def on_erase(self, addr, size):
        self.chars[addr:addr+size] = ['\xff'] * size

class SpiffsFileBack(Spiffs):
    def __init__(self, fd, phys_addr, blocksize, pagesize):
        self.back_fd = fd
        fd.seek(0,2) # to the end
        size = fd.tell()
        super(SpiffsFileBack, self).__init__(size, 
                phys_addr, 
                blocksize, #phys_erase_block 
                pagesize, #log_page_size
                blocksize) #log_block_size

    def on_read(self, addr, size):
        self.back_fd.seek(addr)
        return self.back_fd.read(size)

    def on_write(self, addr, data):
        self.back_fd.seek(addr)
        was_data = self.back_fd.read(len(data))
        is_data = []

        for was,new in zip(was_data,data):
            now = ord(was) & ord(new)
            is_data.append(chr(now))

        self.back_fd.seek(addr)
        self.back_fd.write(''.join(is_data))

    def on_erase(self, addr, size):
        self.back_fd.seek(addr)
        self.back_fd.write('\xff'*size)

def _destructive_tests(spiffs_mount):
    """Tests that the callbacks are implemented OK.
    These tests will damage the filesystem."""

    print("destructive test")
    s = spiffs_mount

    addr = s.phys_erase_block
    size = s.phys_erase_block
    old_data = s.on_read(addr, size)
    s.on_erase(addr, size)
    erased = s.on_read(addr, size)
    assert erased == '\xff'*size
    print("erased ok")

    data = ''.join(chr(x & 0xff) for x in range(size))
    s.on_write(addr,data)
    readback = s.on_read(addr,size)
    assert readback==data
    print("wrote ok")

    data2 = '\0'*10
    s.on_write(addr+10,data2)
    readback = s.on_read(addr,size)
    assert readback[20:]==data[20:]
    assert readback[:10]==data[:10]
    print("part write ok")
    assert readback[10:20]==data2
    print("part write ok")

    s.on_write(addr+size, data)
    s.on_erase(addr,size)
    readback = s.on_read(addr+size,size)
    assert readback==data
    print("erase bounded ok")

    s.on_write(addr, data)
    data2 = ''.join(chr(0xff^ord(c)) for c in data)
    s.on_write(addr, data2)
    readback = s.on_read(addr,size)
    assert readback=='\0'*size
    print("AND ok")

def _tests(spiffs_mount):
    s = spiffs_mount
    print(s.dir())

    fd = s.fopen("Hello", SPIFFS_CREAT | SPIFFS_WRONLY)
    print(fd)
    s.fwrite(fd, "Hello World")
    s.fclose(fd)

    print(s.dir())

    with s.open("Testfile","w") as tf:
        for x in range(100):
            print >> tf, "Test message",x,
            # print("Test message", x, file=tf)

    print(s.dir())
    print(s.open("Testfile").read())

    print(s.dir())
    s.remove("Testfile")

    print(s.dir())

def main():
    parser = argparse.ArgumentParser(description='VATICS-RTOS Create SPIFFS image tool', prog='mkspiffs')
    parser.add_argument(
        '--Dir', '-D',
        help="Directory with files that will be put in SPIFFS image"),
    parser.add_argument(
        '--file', '-f', default='ffs.img',
        help="SPIFFS image file name, default=ffs.img"),
    parser.add_argument(
        '--size', '-s', type=int,
        help="SPIFFS image file size (note: need use Decimal)"),
    parser.add_argument(
        '--pagesize', '-p', type=int, default=512,
        help="Logic page size, default=512 (note: need use Decimal)"),
    parser.add_argument(
        '--blocksize', '-b', type=int, default=65536,
        help="Logic block size, default=65536 (note: need use Decimal)"),
    parser.add_argument(
        '--interactive', '-i', type=int, default=0,
        help="command interactive (enable = 1) , default=0"
        "  Support Command:"
        "   * ls : List contents"
        "   * cat <filename>"
        "   * import <srcfile> <spiffsname>"
        "   * export <spiffsname> <dstfile>"),
    
    args = parser.parse_args()
    
    '''
    Command Interactive:
        * ls : List contents
        * cat <filename>
        * import <srcfile> <spiffsname>
        * export <spiffsname> <dstfile>
    '''
    if args.interactive == 1:
        with file(args.file,'r+wb') as bf:
            s = SpiffsFileBack(bf, 0, args.blocksize, args.pagesize)

            while 1:
                input_string = raw_input("> ")
                cmd = input_string.split(' ', 1)[0]

                if cmd == 'ls':
                    print("[name, size, id]")
                    for x in s.dir():
                        print(x)
                elif cmd == 'cat':
                    cat_path = input_string.split(' ', 1)[1]
                    fd = s.fopen(cat_path, SPIFFS_RDONLY)
                    pos = s.ftell(fd)
                    size = s.fseek(fd, 0, SPIFFS_SEEK_END)
                    s.fseek(fd, pos)
                    count = size - pos
                    cat_buf = ''.join(s.fread(fd, count))
                    s.fclose(fd)
                    print(cat_buf)
                elif cmd == 'rm':
                    rm_path = input_string.split(' ', 1)[1]
                    s.remove(rm_path)
                    print("remove %s") % (rm_path)
                elif cmd == 'import':
                    if len(input_string.split(' ')) < 3:
                        print("command is error")
                        continue

                    import_src = input_string.split(' ')[1]
                    import_ffs_path = input_string.split(' ')[2]
                    
                    print("import %s -> %s") % (import_src, import_ffs_path)
                    
                    import_buf = ''
                    import_buf = open(import_src, 'r').read()
                
                    fd = s.fopen(import_ffs_path, SPIFFS_CREAT | SPIFFS_WRONLY)
                    s.fwrite(fd, import_buf)
                    s.fclose(fd)
                elif cmd == 'export':
                    if len(input_string.split(' ')) < 3:
                        print("command is error")
                        continue

                    ex_ffs_path = input_string.split(' ')[1]
                    ex_dst = input_string.split(' ')[2]
                    print("export %s -> %s") % (ex_ffs_path, ex_dst)
                    
                    fd = s.fopen(ex_ffs_path, SPIFFS_RDONLY)
                    pos = s.ftell(fd)
                    size = s.fseek(fd, 0, SPIFFS_SEEK_END)
                    s.fseek(fd, pos)
                    count = size - pos
                    ex_buf = ''.join(s.fread(fd, count))
                    s.fclose(fd)

                    open(ex_dst, "w").write(ex_buf)
                elif cmd == 'download':
                    cwd = os.getcwd()
                    download_folder = os.path.join(cwd, 'download')
                    for x in s.dir():
                        # print(x[0])
                        fd = s.fopen(x[0], SPIFFS_RDONLY)
                        pos = s.ftell(fd)
                        size = s.fseek(fd, 0, SPIFFS_SEEK_END)
                        s.fseek(fd, pos)
                        count = size - pos
                        ex_buf = ''
                        ex_buf = ''.join(s.fread(fd, count))
                        s.fclose(fd)
                        
                        ex_ffs_path = os.path.join(download_folder, x[0])
                        print("export %s") % (ex_ffs_path)
                        
                        if not os.path.exists(os.path.dirname(ex_ffs_path)):
                            try:
                                os.makedirs(os.path.dirname(ex_ffs_path))
                            except OSError as exc: # Guard against race condition
                                if exc.errno != errno.EEXIST:
                                    raise

                        with open(ex_ffs_path, "w") as f:
                            f.write(ex_buf)
                elif cmd == 'quit':
                    return
                elif cmd == 'help':
                    print("Support Command: \n"
                            "  * ls : List contents\n"
                            "  * cat <filename>\n"
                            "  * import <srcfile> <spiffsname>\n"
                            "  * export <spiffsname> <dstfile>\n"
                            "  * download : export all file to download folder\n"
                            "  * quit : leave interactive command\n"
                            "  * help: help command\n")
                else:
                    print("command is not found")

    
    if args.Dir is None:
        print("Please specify one with the --Dir option.\n")
        sys.exit(1)
    # elif not os.path.exists(args.Dir):
        # print("Directory '%s' not found \n" % args.Dir)
        # print("Please specify one with the --Dir option.\n")
        # sys.exit(1)
    
    if args.size is None:
        print("Please specify one with the --size option.\n")
        sys.exit(1)
    elif args.size < args.blocksize * 2:
        print("file size need be twice bigger than flash block size")
        sys.exit(1)
    elif args.size & (args.blocksize -1):
        print("file size not multiple of erase block size")

    ######################################################################### 
    print("Create Spiffs Filesystem Image ...")
    print(" -- file %s size 0x%x block_size 0x%x page_size 0x%x") % (args.file, 
            args.size, args.blocksize, args.pagesize)
    print(" -- Directory %s") % (args.Dir)
    file(args.file,'w').write('\xff'*args.size)
    
    with file(args.file,'r+wb') as bf:
        s = SpiffsFileBack(bf, 0, args.blocksize, args.pagesize)
        
        for root, dirs, files in os.walk(args.Dir):
            for f in files:
                target_file_path = os.path.join(root, f)
                buf = ''
                buf += open(target_file_path, 'r').read()

                if args.Dir.endswith('/'):
                    ffs_path = target_file_path.replace(args.Dir , '', 1)
                else:
                    ffs_path = target_file_path.replace(args.Dir + '/', '', 1)
                
                print("> import %s -> %s") % (target_file_path, ffs_path)
                fd = s.fopen(ffs_path, SPIFFS_CREAT | SPIFFS_WRONLY)
                s.fwrite(fd, buf)
                s.fclose(fd)

        print("Export SPIFFS Image to %s ...") % (args.file)

if __name__=="__main__":
    main()

    '''
    # Unit Test
    file('/tmp/back.bin','w').write('\xff'*8*1024*1024)

    with file('/tmp/back.bin','r+wb') as bf:
        s = SpiffsFileBack(bf)
        _tests(s)
        _destructive_tests(s)

    loc=['\xff']*4*1024*1024
    s = SpiffsCharsBack(loc)
    _tests(s)
    _destructive_tests(s)
    '''
