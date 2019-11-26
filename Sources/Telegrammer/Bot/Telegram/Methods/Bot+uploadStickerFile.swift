// Telegrammer - Telegram Bot Swift SDK.
// This file is autogenerated by API/generate_wrappers.rb script.



public extension Bot {

    /// Parameters container struct for `uploadStickerFile` method
    struct UploadStickerFileParams: MultipartEncodable {

        /// User identifier of sticker file owner
        var userId: Int64

        /// Png image with the sticker, must be up to 512 kilobytes in size, dimensions must not exceed 512px, and either width or height must be exactly 512px. More info on Sending Files »
        var pngSticker: InputFile

        /// Custom keys for coding/decoding `UploadStickerFileParams` struct
        enum CodingKeys: String, CodingKey {
            case userId = "user_id"
            case pngSticker = "png_sticker"
        }

        public init(userId: Int64, pngSticker: InputFile) {
            self.userId = userId
            self.pngSticker = pngSticker
        }
    }

    /**
     Use this method to upload a .png file with a sticker for later use in createNewStickerSet and addStickerToSet methods (can be used multiple times). Returns the uploaded File on success.

     SeeAlso Telegram Bot API Reference:
     [UploadStickerFileParams](https://core.telegram.org/bots/api#uploadstickerfile)
     
     - Parameters:
         - params: Parameters container, see `UploadStickerFileParams` struct
     - Throws: Throws on errors
     - Returns: Future of `File` type
     */
    @discardableResult
    func uploadStickerFile(params: UploadStickerFileParams) throws -> Future<File> {
        let body = try httpBody(for: params)
        let headers = httpHeaders(for: params)
        let response: Future<TelegramContainer<File>>
        response = try client.respond(endpoint: "uploadStickerFile", body: body, headers: headers)
        return response.flatMapThrowing { (container) -> File in
            return try self.processContainer(container)
        }
    }
}
