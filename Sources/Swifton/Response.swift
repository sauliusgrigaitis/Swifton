import S4

public enum ContentType: String {
    case HTML           = "text/html"
    case JSON           = "application/json"
    case Plain          = "text/plain"
    case CSS            = "text/css"
    case XML            = "text/xml"
    case GIF            = "image/gif"
    case JPEG           = "image/jpeg"
    case JavaScript     = "application/javascript"
    case Atom           = "application/atom+xml"
    case RSS            = "application/rss+xml"
    case MML            = "text/mathml"
    case JAD            = "text/vnd.sun.j2me.app-descriptor"
    case WML            = "text/vnd.wap.wml"
    case HTC            = "text/x-component"
    case PNG            = "image/png"
    case TIFF           = "image/tiff"
    case WBMP           = "image/vnd.wap.wbmp"
    case ICO            = "image/x-icon"
    case JNG            = "image/x-jng"
    case BMP            = "image/x-ms-bmp"
    case SVG            = "image/svg+xml"
    case WEBP           = "image/webp"
    case WOFF           = "application/font-woff"
    case JavaArchive    = "application/java-archive"
    case HQX            = "application/mac-binhex40"
    case DOC            = "application/msword"
    case PDF            = "application/pdf"
    case PostScript     = "application/postscript"
    case Rich           = "application/rtf"
    case M3U8           = "application/vnd.apple.mpegurl"
    case Excel          = "application/vnd.ms-excel"
    case EOT            = "application/vnd.ms-fontobject"
    case Powerpoint     = "application/vnd.ms-powerpoint"
    case WMLC           = "application/vnd.wap.wmlc"
    case KML            = "application/vnd.google-earth.kml+xml"
    case KMZ            = "application/vnd.google-earth.kmz"
    case SevenZ         = "application/x-7z-compressed"
    case CCO            = "application/x-cocoa"
    case JARDIFF        = "application/x-java-archive-diff"
    case JNLP           = "application/x-java-jnlp-file"
    case RUN            = "application/x-makeself"
    case Perl           = "application/x-perl"
    case Pilot          = "application/x-pilot"
    case RAR            = "application/x-rar-compressed"
    case RPM            = "application/x-redhat-package-manager"
    case SEA            = "application/x-sea"
    case SWF            = "application/x-shockwave-flash"
    case SIT            = "application/x-stuffit"
    case TCL            = "application/x-tcl"
    case Certificate    = "application/x-x509-ca-cert"
    case XPI            = "application/x-xpinstall"
    case XHTML          = "application/xhtml+xml"
    case XSPF           = "application/xspf+xml"
    case ZIP            = "application/zip"
    case OctetStream    = "application/octet-stream"
    case DOCX           = "application/vnd.openxmlformats-officedocument.wordprocessingml.document"
    case XLSX           = "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
    case PPTX           = "application/vnd.openxmlformats-officedocument.presentationml.presentation"
    case MIDI           = "audio/midi"
    case MP3            = "audio/mpeg"
    case OGG            = "audio/ogg"
    case M4A            = "audio/x-m4a"
    case RA             = "audio/x-realaudio"
    case ThreeGP        = "video/3gpp"
    case TS             = "video/mp2t"
    case MP4            = "video/mp4"
    case MPEG           = "video/mpeg"
    case MOV            = "video/quicktime"
    case WEBM           = "video/webm"
    case FLV            = "video/x-flv"
    case M4V            = "video/x-m4v"
    case MNG            = "video/x-mng"
    case ASF            = "video/x-ms-asf"
    case WMV            = "video/x-ms-wmv"
    case AVI            = "video/x-msvideo"
}

extension Response {

    public var cookies: [String: String] {
        get {
            return storage["swifton-cookies"] as? [String: String] ?? [:]
        }

        set(cookies) {
            storage["swifton-cookies"] = cookies
        }
    }

    public var bodyString: String? {
        var mutatingBody = body
        let buffer = try? mutatingBody.becomeBuffer()
        return buffer?.description
    }

    init(status: Status, contentType: ContentType, body: String) {
        let contentTypeHeaderValue = Header("\(contentType.rawValue); charset=utf8")
        let headers: Headers = ["Content-Type": contentTypeHeaderValue]
        self.init(status: status, headers: headers, body: body.data)
    }

}
