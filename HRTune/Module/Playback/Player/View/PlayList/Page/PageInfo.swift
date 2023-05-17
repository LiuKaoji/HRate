import UIKit
import AEAudio

struct PageInfo {
    var title: String
    var details: String
    var image: UIImage?
    var icon: UIImage?
}

extension PageInfo {
    static var infos: [PageInfo] {
        var infos = [PageInfo]()
        infos.append(
            PageInfo(
                title: "已录制",
                details: "录制历史列表",
                image: P.image.cover(),
                icon: P.image.waveform()
            )
        )
        
        infos.append(
            PageInfo(
                title: "音频包",
                details: "自定义音频包列表",
                image: P.image.cover(),
                icon: P.image.musiclist()
            )
        )
        
        infos.append(
            PageInfo(
                title: "收藏夹",
                details: "收藏的音乐列表",
                image: P.image.cover(),
                icon: P.image.favorList()
            )
        )
        return infos
    }
}
