/*
 * Copyright (c) 2003-2016 GameDuell GmbH, All Rights Reserved
 * This document is strictly confidential and sole property of GameDuell GmbH, Berlin, Germany
 */
package duell.build.plugin.library.svgcompiler;

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
    private static inline var PACK_CONFIGURATION_FILE: String = "pack.json";
    inline static private var TMP_FOLDER: String = "_tmp";

    private var pathToAtlasPackerStagingArea: String;

    private var atlasPathList: Array<String> = [];

    private var sourceToTargetPathMap: Map<String, String> = new Map<String, String>();
    private var hashChangedMap: Map<String, Bool> = new Map<String, Bool>();

    public function new()
    {}

    public function postParse(): Void
    {
        trace("postParse()");

        // Atlas not needed for unknown plattform or unitylayout
        if (Configuration.getData().PLATFORM == null || Configuration.getData().PLATFORM.PLATFORM_NAME == "unitylayout")
            return;

        // if no parsing is made we need to add the default state
        //if (Configuration.getData().LIBRARY.ATLASPACKER == null)
        //{
        //    Configuration.getData().LIBRARY.ATLASPACKER = LibraryConfiguration.getData();
        //}


        pathToAtlasPackerStagingArea = Path.join([Configuration.getData().OUTPUT, "svgcompiler", "temp"]);
        PathHelper.mkdir(pathToAtlasPackerStagingArea);


        AssetProcessorRegister.registerProcessor(process, AssetProcessorPriority.AssetProcessorPriorityMedium, 0);

        //var data = new Data(1000);
        //data.readFloat32();

        //var element = SVGElement.create();
        //element.fill_none();

        var stream: StreamInterface = null;
        var svgData = new SVGData();
        SvgSerializer.writeSvgData(stream, svgData);
    }

    private function process(): Void
    {
        trace("process()");
        /*for (cfg in customAtlasList)
        {
            if (filesChanged(cfg.files) || folderChanged(Path.directory(cfg.pack)))
            {
             //processCustomAtlas(cfg);
            }
        }*/

        for (atlasPath in atlasPathList)
        {
            if (folderChanged(atlasPath))
            {
                //processNormalAtlas(atlasPath);
            }
        }
    }

    private function filesChanged(files: Array<String>): Bool
    {
        return files.filter(function(file: String) {
            return folderChanged(Path.directory(file));
        }).length != 0;
    }

    private function folderChanged(path: String): Bool
    {
        for (changedPath in AssetProcessorRegister.foldersThatChanged)
        {
            if (changedPath == Path.addTrailingSlash(path) || changedPath.indexOf(path) == 0)
                return true;
        }
        return false;
    }

    private function getPathToStagingArea(path: String): String
    {
        if (sourceToTargetPathMap.exists(path))
        {
            return sourceToTargetPathMap.get(path);
        }
        return path;
    }

}
