// Telegrammer - Telegram Bot Swift SDK.
// This file is autogenerated by API/generate_wrappers.rb script.



public extension Bot {

    /// Parameters container struct for `createNewStickerSet` method
    struct CreateNewStickerSetParams: MultipartEncodable {

        /// User identifier of created sticker set owner
        var userId: Int64

        /// Short name of sticker set, to be used in t.me/addstickers/ URLs (e.g., animals). Can contain only english letters, digits and underscores. Must begin with a letter, can't contain consecutive underscores and must end in “_by_<bot username>”. <bot_username> is case insensitive. 1-64 characters.
        var name: String

        /// Sticker set title, 1-64 characters
        var title: String

        /// Png image with the sticker, must be up to 512 kilobytes in size, dimensions must not exceed 512px, and either width or height must be exactly 512px. Pass a file_id as a String to send a file that already exists on the Telegram servers, pass an HTTP URL as a String for Telegram to get a file from the Internet, or upload a new one using multipart/form-data. More info on Sending Files »
        var pngSticker: FileInfo

        /// One or more emoji corresponding to the sticker
        var emojis: String

        /// Pass True, if a set of mask stickers should be created
        var containsMasks: Bool?

        /// A JSON-serialized object for position where the mask should be placed on faces
        var maskPosition: MaskPosition?

        /// Custom keys for coding/decoding `CreateNewStickerSetParams` struct
        enum CodingKeys: String, CodingKey {
            case userId = "user_id"
            case name = "name"
            case title = "title"
            case pngSticker = "png_sticker"
            case emojis = "emojis"
            case containsMasks = "contains_masks"
            case maskPosition = "mask_position"
        }

        public init(userId: Int64, name: String, title: String, pngSticker: FileInfo, emojis: String, containsMasks: Bool? = nil, maskPosition: MaskPosition? = nil) {
            self.userId = userId
            self.name = name
            self.title = title
            self.pngSticker = pngSticker
            self.emojis = emojis
            self.containsMasks = containsMasks
            self.maskPosition = maskPosition
        }
    }

    /**
     Use this method to create new sticker set owned by a user. The bot will be able to edit the created sticker set. Returns True on success.

     SeeAlso Telegram Bot API Reference:
     [CreateNewStickerSetParams](https://core.telegram.org/bots/api#createnewstickerset)
     
     - Parameters:
         - params: Parameters container, see `CreateNewStickerSetParams` struct
     - Throws: Throws on errors
     - Returns: Future of `Bool` type
     */
    @discardableResult
    func createNewStickerSet(params: CreateNewStickerSetParams) throws -> Future<Bool> {
        let body = try httpBody(for: params)
        let headers = httpHeaders(for: params)
        let response: Future<TelegramContainer<Bool>>
        response = try client.respond(endpoint: "createNewStickerSet", body: body, headers: headers)
        return response.flatMapThrowing { (container) -> Bool in
            return try self.processContainer(container)
        }
    }
}
