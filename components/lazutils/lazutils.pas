{ This file was automatically created by Lazarus. Do not edit!
  This source is only used to compile and install the package.
 }

unit LazUtils;

{$warn 5023 off : no warning about unused units}
interface

uses
  AvgLvlTree, CodepagesAsian, CodepagesCommon, CompWriterPas, DynamicArray, 
  DynHashArray, DynQueue, ExtendedStrings, FileReferenceList, FileUtil, 
  FPCAdds, GraphMath, GraphType, HTML2TextRender, IntegerList, Laz2_DOM, 
  Laz2_XMLCfg, Laz2_XMLRead, Laz2_XMLUtils, Laz2_XMLWrite, Laz2_XPath, 
  Laz_DOM, Laz_XMLCfg, Laz_XMLRead, Laz_XMLStreaming, Laz_XMLWrite, 
  LazClasses, lazCollections, LazConfigStorage, LazDbgLog, LazFglHash, 
  LazFileCache, LazFileUtils, LazLinkedList, LazListClasses, LazLogger, 
  LazLoggerBase, LazLoggerDummy, LazLoggerProfiling, LazMethodList, 
  LazPasReadUtil, LazStringUtils, LazSysUtils, LazTracer, LazUnicode, 
  LazUTF16, LazUTF8, LazUtilities, LazUtilsStrConsts, LazVersion, 
  LConvEncoding, LCSVUtils, LookupStringList, Maps, Masks, ObjectLists, 
  StringHashList, TextStrings, Translations, UTF8Process, PList2JSon, 
  LazarusPackageIntf;

implementation

procedure Register;
begin
end;

initialization
  RegisterPackage('LazUtils', @Register);
end.
