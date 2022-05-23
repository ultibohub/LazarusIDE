unit stubs.web;

uses stubs.js;

Type
  TEventListenerEvent = class (TJSObject);
  TJSEventTarget = class (TJSObject);
  TJSNode = class (TJSEventTarget);
  TJSNodeList = class (TJSObject);
  TJSAttr = class (TJSNode);
  TJSNamedNodeMap = class (TJSObject);
  TJSHTMLCollection = class (TJSObject);
  TJSDOMTokenList = class (TJSObject);
  TJSDOMRect = class (TJSObject);
  TJSElement = class (TJSNode);
  TJSDocumentType = class (TJSNode);
  TJSDOMImplementation = class (TJSObject);
  TJSLocation = class (TJSObject);
  TJSStyleSheet = class (TJSEventTarget);
  TJSCSSRule = class (TJSObject);
  TJSCSSStyleRule = class (TJSCSSRule);
  TJSCSSStyleSheet = class (TJSStyleSheet);
  TJSEvent = class (TJSObject);
  TJSXPathExpression = class (TJSObject);
  TJSXPathNSResolver = class (TJSObject);
  TJSCharacterData = class (TJSNode);
  TJSProcessingInstruction = class (TJSCharacterData);
  TJSRange = class (TJSObject);
  TJSTreeWalker = class (TJSObject);
  TJSNodeFilter = class (TJSObject);
  TJSXPathResult = class (TJSObject);
  TJSSelection = class (TJSObject);
  TJSHTMLFile = class;;
  TJSDataTransferItem = class (TJSObject);
  TJSDataTransferItemList = class (TJSObject);
  TJSDataTransfer = class (TJSObject);
  TJSDragEvent = class (TJSEvent);
  TJSErrorEvent = class (TJSEvent);
  TJSPageTransitionEvent = class(TJSEvent);
  TJSHashChangeEvent = class (TJSEvent);
  TJSPopStateEvent = class (TJSEvent);
  TJSStorageEvent = class (TJSEvent);
  TJSProgressEvent = class (TJSEvent);
  TJSCloseEvent = class (TJSEvent);
  TJSDocument = class (TJSNode);
  TJSConsole = class (TJSObject);
  // TJSBufferSource = class end;;
  // TJSTypedArray = class end;;
  TJSCryptoKey = class ;
  TJSSubtleCrypto = class ;
  TJSCrypto = class (TJSObject);
  TJSHistory = class (TJSObject);
  TJSIDBTransactionMode = class;
  TJSIDBTransaction = class (TJSEventTarget);
  TJSIDBKeyRange = class (TJSObject);
  TJSIDBIndex = class (TJSObject);
  TJSIDBCursorDirection = class (TJSObject);
  TJSIDBCursor = class (TJSObject);
  TJSIDBObjectStore = class (TJSEventTarget);
  TJSIDBRequest = class (TJSEventTarget);
  TJSIDBOpenDBRequest = class (TJSIDBRequest);
  TIDBDatabase = class (TJSEventTarget);
  TJSIDBFactory = class (TJSEventTarget);
  TJSStorage = class (TJSEventTarget);
  TJSVisibleItem = class (TJSObject);
  TJSLocationBar = class (TJSVisibleItem);;
  TJSMenuBar = class (TJSVisibleItem);;
  TJSToolBar = class (TJSVisibleItem);;
  TJSPersonalBar = class (TJSVisibleItem);;
  TJSScrollBars = class (TJSVisibleItem);;
  TJSGeoLocation = class (TJSObject);
  TJSMediaStreamTrack = class (TJSEventTarget);
  TJSMediaDevices = class (TJSEventTarget);
  TJSWorker = class (TJSEventTarget);
  TJSMessagePort = class (TJSEventTarget);
  TJSSharedWorker = class (TJSEventTarget);
  TJSExtendableEvent = class (TJSEvent);
  TJSExtendableMessageEvent = class (TJSExtendableEvent);
  TJSFetchEvent = class (TJSExtendableEvent);
  TJSClient = class (TJSObject);
  TJSServiceWorker = class (TJSWorker);
  TJSNavigationPreloadState = class ;
  TJSNavigationPreload = class (TJSObject);
  TJSServiceWorkerRegistration = class (TJSObject);
  TJSServiceWorkerContainer = class (TJSObject);
  TJSClipBoard = class (TJSEventTarget);
  TJSNavigator = class (TJSObject);
  TJSTouch = class (TJSObject);
  TJSTouchList = class (TJSObject);
  TJSPerformance = class (TJSObject);;
  TJSScreen = class (TJSObject);
  TJSURLSearchParams = class (TJSObject);
  TJSURL = class (TJSObject);
  TJSMediaQueryList = class (TJSObject);
  TJSReadableStream = class (TJSObject);
  TJSWritableStream = class (TJSObject);
  TJSBody = class (TJSObject);
  TJSResponse = class (TJSBody);
  TJSPostMessageOptions = class (TJSObject);
  TJSIdleCallbackOptions = class;
  TJSIdleDeadline = class ;
  TJSCacheDeleteOptions = class (TJSObject);
  TJSRequest = class (TJSObject);
  TJSCache = class (TJSObject);
  TJSCacheStorage = class (TJSObject);
  TJSWindow = class (TJSObject);
  TJSCSSStyleDeclaration = class (TJSObject);
  TJSScrollIntoViewOptions = class (TJSObject);
  TJSHTMLElement = class (TJSElement);
  TJSHTMLDivElement = class (TJSHTMLElement);
  TJSHTMLFormControlsCollection = class (TJSHTMLCollection);
  TJSHTMLFormElement = class (TJSHTMLElement);
  TJSValidityState = class (TJSObject);
  TJSBlob = class (TJSEventTarget);
  TJSHTMLFile = class (TJSBlob);
  TJSHTMLFileList = class (TJSEventTarget);
  TJSHTMLInputElement = class (TJSHTMLElement);
  TJSDOMSettableTokenList = class (TJSDOMTokenList);
  TJSHTMLOutputElement = class (TJSHTMLElement);
  TJSHTMLImageElement = class (TJSHTMLElement);
  TJSHTMLLinkElement = class (TJSHTMLElement);
  TJSHTMLAnchorElement = class (TJSHTMLElement);
  TJSHTMLMenuElement = class (TJSHTMLElement);
  TJSHTMLButtonElement = class (TJSHTMLElement);
  TJSHTMLLabelElement = class (TJSHTMLElement);
  TJSHTMLTextAreaElement = class (TJSHTMLElement);
  TJSHTMLEmbedElement = class (TJSHTMLElement);
  TJSHTMLOptionElement = class (TJSHTMLElement);
  TJSHTMLOptGroupElement = class (TJSHTMLElement);
  TJSHTMLOptionsCollection = class (TJSHTMLCollection);
  TJSHTMLTableSectionElement = class;;
  TJSHTMLTableRowElement = class;;
  TJSHTMLProgressElement = class (TJSHTMLElement);
  TJSDOMException = class (TJSObject);
  TJSFileReader = class (TJSEventTarget);
  TJSCanvasGradient = class (TJSObject);
  TJSCanvasPattern = class (TJSObject);
  TJSPath2D = class (TJSObject);
  TJSImageData = class (TJSObject);
  TJSTextMetrics = class (TJSObject);
  TJSCanvasRenderingContext2D = class (TJSObject);
  TJSXMLHttpRequestEventTarget = class (TJSEventTarget);
  TJSXMLHttpRequestUpload = class (TJSXMLHttpRequestEventTarget);
  TJSXMLHttpRequest = class (TJSXMLHttpRequestEventTarget);
  TJSUIEvent = class (TJSEvent);
  TJSMouseEvent = class (TJSUIevent);
  TJSWheelEvent = class (TJSMouseEvent);
  TJSKeyboardEvent = class (TJSUIEvent);
  TJSMutationObserver = class (TJSObject);
  TJSMessageEvent = class (TEventListenerEvent);
  TJSWebSocket = class (TJSEventTarget);
  TJSHTMLAudioTrack = class (TJSObject);
  TJSHTMLAudioTrackList = class (TJSObject);
  TJSHTMLVideoTrack = class (TJSObject);
  TJSHTMLVideoTrackList = class (TJSObject);
  TJSHTMLTextTrack = class (TJSObject);
  TJSHTMLTextTrackList = class (TJSObject);
  TJSMEdiaError = class (TJSObject);
  TJSHTMLMediaStream = class (TJSObject);;
  TJSHTMLMediaController = class (TJSObject);;
  TJSHTMLStyleElement = class (TJSHTMLElement);
  TJSHTMLTemplateElement = class (TJSHTMLElement);
  TJSPermissionDescriptor = class (TJSObject);
  TJSPermissionStatus = class (TJSObject);
  TJSPermissions = class (TJSObject);
  TJSFileSystemHandlePermissionDescriptor = class (TJSObject);
  TJSFileSystemCreateWritableOptions = class (TJSObject);
  TJSFileSystemWritableFileStream = class;;
  TJSFileSystemHandle = class (TJSObject);
  TJSFileSystemFileHandle = class (TJSFileSystemHandle);
  TJSGetFileHandleOptions = class ;
  TJSRemoveEntryOptions = class (TJSObject);
  TJSFileSystemDirectoryHandle = class (TJSFileSystemHandle);
  TJSFileSystemWritableFileStream = class (TJSWritableStream);
  TJSShowOpenFilePickerTypeOptions = class (TJSObject);
  TJSShowOpenFilePickerOptions = class (TJSObject);
  TJSShowSaveFilePickerOptionsAccept = class (TJSObject);
  TJSShowSaveFilePickerOptions = class (TJSObject);

implementation

end.
