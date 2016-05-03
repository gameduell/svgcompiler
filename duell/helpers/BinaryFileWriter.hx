package duell.helpers;


import sys.io.File;
import sys.io.FileOutput;
import haxe.io.Bytes;
import aggx.core.StreamInterface;

class BinaryFileWriter implements StreamInterface
{
    private var bytes: Bytes;
    private var file: FileOutput = null;

    public function new()
    {
        bytes = Bytes.alloc(4);
    }

    public function open(filename: String)
    {
        if (file != null)
        {
            close();
        }

        file = File.write(filename, true);
    }

    public function close()
    {
        if (file == null)
        {
            return;
        }

        file.flush();
        file.close();
        file = null;
    }

    public function writeUInt8(v: Int): Void
    {
        file.writeByte(v);
    }

    public function writeUInt16(v: Int): Void
    {
        bytes.set(1, v >> 8);
        bytes.set(0, v);

        file.writeBytes(bytes, 0, 2);
    }

    public function writeUInt32(v: Int): Void
    {
        bytes.set(3, v >> 24);
        bytes.set(2, v >> 16);
        bytes.set(1, v >> 8);
        bytes.set(0, v);

        file.writeBytes(bytes, 0, 4);
    }

    public function writeFloat32(value: Float): Void
    {
        bytes.setFloat(0, value);
        file.writeBytes(bytes, 0, 4);
    }

    public function preallocate(next: Int): Void
    {

    }

    public function readUInt8(): Int
    {
        throw "Unimplemented";
    }

    public function readUInt16(): Int
    {
        throw "Unimplemented";
    }

    public function readUInt32(): Int
    {
        throw "Unimplemented";
    }

    public function readFloat32(): Float
    {
        throw "Unimplemented";
    }
}