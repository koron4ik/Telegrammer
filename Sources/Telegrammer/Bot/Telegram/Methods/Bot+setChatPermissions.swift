// Telegrammer - Telegram Bot Swift SDK.
// This file is autogenerated by API/generate_wrappers.rb script.

public extension Bot {

    /// Parameters container struct for `setChatPermissions` method
    struct SetChatPermissionsParams: JSONEncodable {

        /// Unique identifier for the target chat or username of the target supergroup (in the format @supergroupusername)
        var chatId: ChatId

        /// New default chat permissions
        var permissions: ChatPermissions

        /// Custom keys for coding/decoding `SetChatPermissionsParams` struct
        enum CodingKeys: String, CodingKey {
            case chatId = "chat_id"
            case permissions = "permissions"
        }

        public init(chatId: ChatId, permissions: ChatPermissions) {
            self.chatId = chatId
            self.permissions = permissions
        }
    }

    /**
     Use this method to set default chat permissions for all members. The bot must be an administrator in the group or a supergroup for this to work and must have the can_restrict_members admin rights. Returns True on success.

     SeeAlso Telegram Bot API Reference:
     [SetChatPermissionsParams](https://core.telegram.org/bots/api#setchatpermissions)
     
     - Parameters:
         - params: Parameters container, see `SetChatPermissionsParams` struct
     - Throws: Throws on errors
     - Returns: Future of `Bool` type
     */
    @discardableResult
    func setChatPermissions(params: SetChatPermissionsParams) throws -> Future<Bool> {
        let body = try httpBody(for: params)
        let headers = httpHeaders(for: params)
        return try client
            .request(endpoint: "setChatPermissions", body: body, headers: headers)
            .flatMapThrowing { (container) -> Bool in
                return try self.processContainer(container)
        }
    }
}
