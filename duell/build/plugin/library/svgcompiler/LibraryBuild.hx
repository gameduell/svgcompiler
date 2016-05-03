/*
 * Copyright (c) 2003-2016 GameDuell GmbH, All Rights Reserved
 * This document is strictly confidential and sole property of GameDuell GmbH, Berlin, Germany
 */
package duell.build.plugin.library.svgcompiler;

import duell.helpers.BinaryFileWriter;
import aggx.svg.SVGParser;
import aggx.svg.SVGDataBuilder;
import vectorx.svg.SvgSerializer;
import aggx.svg.SVGData;
import aggx.core.StreamInterface;
import aggx.svg.SVGElement;

import duell.build.objects.Configuration;

import duell.build.plugin.library.filesystem.AssetProcessorRegister;
import duell.helpers.CommandHelper;
import duell.helpers.DirHashHelper;
import duell.helpers.FileHelper;
import duell.helpers.LogHelper;
import duell.helpers.PathHelper;
import duell.helpers.PlatformHelper;
import duell.objects.DuellLib;
import haxe.io.Path;
import haxe.Json;
import python.lib.Os;
import sys.FileStat;
import sys.FileSystem;
import sys.io.File;

using duell.helpers.HashHelper;
using StringTools;

class LibraryBuild
{
    private var writer: BinaryFileWriter = new BinaryFileWriter();

    public function new()
    {}

    public function postParse(): Void
    {
        trace("postParse()");

        if (Configuration.getData().PLATFORM == null || Configuration.getData().PLATFORM.PLATFORM_NAME == "unitylayout")
            return;


        AssetProcessorRegister.registerProcessor(process, AssetProcessorPriority.AssetProcessorPriorityMedium, 0);
    }

    private function process(): Void
    {
        trace("process()");
        trace('folders: ${AssetProcessorRegister.foldersThatChanged}');
        for (folder in AssetProcessorRegister.foldersThatChanged)
        {
            var path = Path.join([AssetProcessorRegister.pathToTemporaryAssetArea, folder]);
            trace('path: $path');
            var files = PathHelper.getRecursiveFileListUnderFolder(path);

            for (file in files)
            {
                if (!file.endsWith(".svg") && !file.endsWith(".svg.bytes"))
                {
                    continue;
                }

                var srcPath = Path.join([path, file]);
                var dstPath = srcPath + ".bin";

                processSvg(srcPath, dstPath, file);
            }
        }

        throw "dbg";
    }

    private function processSvg(src: String, dst: String, file: String): Void
    {
        trace('processSvg:\n src: $src\n dst: $dst');

        if (FileSystem.exists(dst))
        {
            FileSystem.deleteFile(dst);
        }

        var content = File.getContent(src);
        //trace(File.getContent(src));

        var builder = new SVGDataBuilder();
        var parser = new SVGParser(builder);
        parser.processXML(Xml.parse(content));
        var svgData: SVGData = builder.data;

        if (svgData.width == 0 || svgData.height == 0)
        {
            LogHelper.warn('Width or height is not specified for svg file $file');
        }

        //trace(svgData.elementStorage);

        writer.open(dst);
        SvgSerializer.writeSvgData(writer, svgData);
        writer.close();

        if (FileSystem.exists(src))
        {
            FileSystem.deleteFile(src);
        }
    }
}
