{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE RecordWildCards #-}

-- | Data structures pertaining to gateway dispatch 'Event's
module Discord.Internal.Types.Events where

import Prelude hiding (id)

import Data.Time.ISO8601 (parseISO8601)
import Data.Time (UTCTime)
import Data.Time.Clock.POSIX (posixSecondsToUTCTime)
import Network.Socket (HostName)

import Data.Aeson
import Data.Aeson.Types
import qualified Data.Aeson.KeyMap as KM
import qualified Data.Text as T

import Discord.Internal.Types.Prelude
import Discord.Internal.Types.Channel
import Discord.Internal.Types.Guild
import Discord.Internal.Types.AuditLog (AuditLogEntry)
import Discord.Internal.Types.AutoModeration (AutoModerationRule, AutoModerationRuleAction, AutoModerationRuleTriggerType)
import Discord.Internal.Types.User (User, GuildMember)
import Discord.Internal.Types.Interactions (Interaction)
import Discord.Internal.Types.Emoji (Emoji)
import Discord.Internal.Types.ScheduledEvents (ScheduledEvent)


-- | Represents possible events sent by discord. Detailed information can be found at <https://discord.com/developers/docs/topics/gateway>.
data Event =
  -- | Contains the initial state information
    Ready                      Int User [GuildUnavailable] T.Text HostName (Maybe Shard) PartialApplication
  -- | Response to a @Resume@ gateway command
  | Resumed                    [T.Text]
  -- | New auto moderation rule was created, requires the AutoModerationConfiguration intent
  | AutoModerationRuleCreate   AutoModerationRule
  -- | Auto moderation rule was changed, requires the AutoModerationConfiguration intent
  | AutoModerationRuleUpdate   AutoModerationRule
  -- | Auto moderation rule was deleted, requires the AutoModerationConfiguration intent
  | AutoModerationRuleDelete   AutoModerationRule
  -- | Action from an auto moderation rule was executed, requires the AutoModerationExecution intent
  | AutoModerationActionExecution  AutoModerationActionExecuteInfo
  -- | new guild channel created
  | ChannelCreate              Channel
  -- | channel was updated
  | ChannelUpdate              Channel
  -- | channel was deleted
  | ChannelDelete              Channel
  -- | thread created, also sent when being added to a private thread
  | ThreadCreate               Channel
  -- | thread was updated
  | ThreadUpdate               Channel
  -- | thread member for the current user was updated
  | ThreadMemberUpdate         ThreadMemberUpdateFields
  -- | thread was deleted
  | ThreadDelete               Channel
  -- | sent when gaining access to a channel, contains all active threads in that channel
  | ThreadListSync             ThreadListSyncFields
  -- | member or the current user was added or removed from a thread
  | ThreadMembersUpdate        ThreadMembersUpdateFields
  -- | message was pinned or unpinned
  | ChannelPinsUpdate          ChannelId (Maybe UTCTime)
  -- | lazy-load for unavailable guild, guild became available, or user joined a new guild
  | GuildCreate                Guild GuildCreateData
  -- | guild was updated
  | GuildUpdate                Guild
  -- | guild became unavailable, or user left/was removed from a guild
  | GuildDelete                GuildUnavailable
  -- | new entry to the audit log was added
  | GuildAuditLogEntryCreate   AuditLogEntry
  -- | user was banned from a guild
  | GuildBanAdd                GuildId User
  -- | user was unbanned from a guild
  | GuildBanRemove             GuildId User
  -- | guild emojis were updated
  | GuildEmojiUpdate           GuildId [Emoji]
  -- | guild integration was updated
  | GuildIntegrationsUpdate    GuildId
  -- | new user joined a guild
  | GuildMemberAdd             GuildId GuildMember
  -- | user was removed from a guild
  | GuildMemberRemove          GuildId User
  -- | guild member was updated
  | GuildMemberUpdate          GuildId [RoleId] User (Maybe T.Text)
  -- | response to @Request Guild Members@ gateway command
  | GuildMemberChunk           GuildId [GuildMember]
  -- | guild role was created
  | GuildRoleCreate            GuildId Role
  -- | guild role was updated
  | GuildRoleUpdate            GuildId Role
  -- | guild role was deleted
  | GuildRoleDelete            GuildId RoleId
  -- | message was created
  | MessageCreate              Message
  -- | message was updated
  | MessageUpdate              ChannelId MessageId
  -- | message was deleted
  | MessageDelete              ChannelId MessageId
  -- | multiple messages were deleted at once
  | MessageDeleteBulk          ChannelId [MessageId]
  -- | user reacted to a message
  | MessageReactionAdd         ReactionInfo
  -- | user removed a reaction from a message
  | MessageReactionRemove      ReactionInfo
  -- | all reactions were explicitly removed from a message
  | MessageReactionRemoveAll   ChannelId MessageId
  -- | all reactions for a given emoji were explicitly removed from a message
  | MessageReactionRemoveEmoji ReactionRemoveInfo
  -- | user was updated
  | PresenceUpdate             PresenceInfo
  -- | user started typing in a channel
  | TypingStart                TypingInfo
  -- | properties about the user changed
  | UserUpdate                 User
  -- | someone joined, left, or moved a voice channel
  | InteractionCreate          Interaction
  --  | VoiceStateUpdate
  --  | VoiceServerUpdate
  -- | An Unknown Event, none of the others
  | UnknownEvent               T.Text Object
  deriving (Show, Eq)

-- | Internal Event representation. Each matches to the corresponding constructor of `Event`.
--
-- An application should never have to use those directly
data EventInternalParse =
    InternalReady                      Int User [GuildUnavailable] T.Text HostName (Maybe Shard) PartialApplication
  | InternalResumed                    [T.Text]
  | InternalAutoModerationRuleCreate   AutoModerationRule
  | InternalAutoModerationRuleUpdate   AutoModerationRule
  | InternalAutoModerationRuleDelete   AutoModerationRule
  | InternalAutoModerationActionExecution AutoModerationActionExecuteInfo
  | InternalChannelCreate              Channel
  | InternalChannelUpdate              Channel
  | InternalChannelDelete              Channel
  | InternalThreadCreate               Channel
  | InternalThreadUpdate               Channel
  | InternalThreadMemberUpdate         ThreadMemberUpdateFields
  | InternalThreadDelete               Channel
  | InternalThreadListSync             ThreadListSyncFields 
  | InternalThreadMembersUpdate        ThreadMembersUpdateFields 
  | InternalChannelPinsUpdate          ChannelId (Maybe UTCTime)
  | InternalGuildCreate                Guild GuildCreateData
  | InternalGuildUpdate                Guild
  | InternalGuildDelete                GuildUnavailable
  | InternalGuildAuditLogEntryCreate   AuditLogEntry
  | InternalGuildBanAdd                GuildId User
  | InternalGuildBanRemove             GuildId User
  | InternalGuildEmojiUpdate           GuildId [Emoji]
  | InternalGuildIntegrationsUpdate    GuildId
  | InternalGuildMemberAdd             GuildId GuildMember
  | InternalGuildMemberRemove          GuildId User
  | InternalGuildMemberUpdate          GuildId [RoleId] User (Maybe T.Text)
  | InternalGuildMemberChunk           GuildId [GuildMember]
  | InternalGuildRoleCreate            GuildId Role
  | InternalGuildRoleUpdate            GuildId Role
  | InternalGuildRoleDelete            GuildId RoleId
  | InternalMessageCreate              Message
  | InternalMessageUpdate              ChannelId MessageId
  | InternalMessageDelete              ChannelId MessageId
  | InternalMessageDeleteBulk          ChannelId [MessageId]
  | InternalMessageReactionAdd         ReactionInfo
  | InternalMessageReactionRemove      ReactionInfo
  | InternalMessageReactionRemoveAll   ChannelId MessageId
  | InternalMessageReactionRemoveEmoji ReactionRemoveInfo
  | InternalPresenceUpdate             PresenceInfo
  | InternalTypingStart                TypingInfo
  | InternalUserUpdate                 User
  | InternalInteractionCreate          Interaction
  --  | InternalVoiceStateUpdate
  --  | InternalVoiceServerUpdate
  | InternalUnknownEvent               T.Text Object
  deriving (Show, Eq, Read)

-- | Structure containing partial information about an Application
data PartialApplication = PartialApplication
  { partialApplicationID :: ApplicationId
  , partialApplicationFlags :: Int
  } deriving (Show, Eq, Read)

instance FromJSON PartialApplication where
  parseJSON = withObject "PartialApplication" (\v -> PartialApplication <$> v .: "id" <*> v .: "flags")

data GuildCreateData = GuildCreateData
  { guildCreateJoinedAt :: !UTCTime
  , guildCreateLarge :: !Bool
  , guildCreateUnavailable :: !(Maybe Bool)
  , guildCreateMemberCount :: !Int
  -- , guildCreateVoiceStates
  , guildCreateMembers :: ![GuildMember]
  , guildCreateChannels :: ![Channel]
  , guildCreateThreads :: ![Channel]
  , guildCreatePresences :: ![PresenceInfo]
  -- , guildStageInstances :: [StageI]
  , guildCreateScheduledEvents :: ![ScheduledEvent]
  } deriving (Show, Eq, Read)

parseGuildCreate :: Object -> Parser EventInternalParse
parseGuildCreate o = do
  guild :: Guild <- reparse o
  let gid = guildId guild
  channelValues :: [Object] <- o .: "channels"
  threadValues :: [Object] <- o .: "threads"
  let wellFormedChannels = fmap (Object . KM.insert "guild_id" (toJSON gid)) channelValues
      wellFormedThreads = fmap (Object . KM.insert "guild_id" (toJSON gid)) threadValues
  guildCreateData <-
    GuildCreateData <$> o .:  "joined_at"
                    <*> o .:  "large"
                    <*> o .:? "unavailable"
                    <*> o .:  "member_count"
                    <*> o .:  "members"
                    <*> traverse parseJSON wellFormedChannels
                    <*> traverse parseJSON wellFormedThreads
                    <*> o .:  "presences"
                    <*> o .:  "guild_scheduled_events"
  pure $ InternalGuildCreate guild guildCreateData

-- | Structure containing information about a reaction
data ReactionInfo = ReactionInfo
  { reactionUserId    :: UserId -- ^ User who reacted
  , reactionGuildId   :: Maybe GuildId -- ^ Guild in which the reacted message is (if any) 
  , reactionChannelId :: ChannelId -- ^ Channel in which the reacted message is
  , reactionMessageId :: MessageId -- ^ The reacted message
  , reactionEmoji     :: Emoji -- ^ The Emoji used for the reaction
  } deriving (Show, Read, Eq, Ord)

instance FromJSON ReactionInfo where
  parseJSON = withObject "ReactionInfo" $ \o ->
    ReactionInfo <$> o .:  "user_id"
                 <*> o .:? "guild_id"
                 <*> o .:  "channel_id"
                 <*> o .:  "message_id"
                 <*> o .:  "emoji"

-- | Structure containing information about a reaction that has been removed
data ReactionRemoveInfo  = ReactionRemoveInfo
  { reactionRemoveChannelId :: ChannelId
  , reactionRemoveGuildId   :: GuildId
  , reactionRemoveMessageId :: MessageId
  , reactionRemoveEmoji     :: Emoji
  } deriving (Show, Read, Eq, Ord)

instance FromJSON ReactionRemoveInfo where
  parseJSON = withObject "ReactionRemoveInfo" $ \o ->
    ReactionRemoveInfo <$> o .:  "guild_id"
                       <*> o .:  "channel_id"
                       <*> o .:  "message_id"
                       <*> o .:  "emoji"

-- | Structre containing typing status information
data TypingInfo = TypingInfo
  { typingUserId    :: UserId
  , typingChannelId :: ChannelId
  , typingTimestamp :: UTCTime
  } deriving (Show, Read, Eq, Ord)

instance FromJSON TypingInfo where
  parseJSON = withObject "TypingInfo" $ \o ->
    do cid <- o .: "channel_id"
       uid <- o .: "user_id"
       posix <- o .: "timestamp"
       let utc = posixSecondsToUTCTime posix
       pure (TypingInfo uid cid utc)

-- | Structure containing auto moderation action execution information
data AutoModerationActionExecuteInfo = AutoModerationActionExecuteInfo
  { autoModerationActionExecuteInfoGuildId        :: GuildId
  , autoModerationActionExecuteInfoAction         :: AutoModerationRuleAction
  , autoModerationActionExecuteInfoRuleId         :: AutoModerationRuleId
  , autoModerationActionExecuteInfoTriggerType    :: AutoModerationRuleTriggerType
  , autoModerationActionExecuteInfoUserId         :: UserId
  , autoModerationActionExecuteInfoChannelId      :: Maybe ChannelId
  , autoModerationActionExecuteInfoMessageId      :: Maybe MessageId
  , autoModerationActionExecuteInfoAlertMessageId :: Maybe MessageId
  , autoModerationActionExecuteInfoContent        :: String
  , autoModerationActionExecuteInfoMatchedKeyword :: Maybe String
  , autoModerationActionExecuteInfoMatchedContent :: Maybe String
  } deriving ( Eq, Show, Read )

instance FromJSON AutoModerationActionExecuteInfo where
  parseJSON = withObject "AutoModerationActionExecuteInfo" $ \o ->
    AutoModerationActionExecuteInfo
      <$> o .:  "guild_id"
      <*> o .:  "action"
      <*> o .:  "rule_id"
      <*> o .:  "rule_trigger_type"
      <*> o .:  "user_id"
      <*> o .:? "channel_id"
      <*> o .:? "message_id"
      <*> o .:? "alert_system_message_id"
      <*> o .:  "content"
      <*> o .:? "matched_keyword"
      <*> o .:? "matched_content"

instance ToJSON AutoModerationActionExecuteInfo where
  toJSON AutoModerationActionExecuteInfo{..} = objectFromMaybes
    [ "guild_id"                  .== autoModerationActionExecuteInfoGuildId
    , "action"                    .== autoModerationActionExecuteInfoAction
    , "rule_id"                   .== autoModerationActionExecuteInfoRuleId
    , "rule_trigger_type"         .== autoModerationActionExecuteInfoTriggerType
    , "user_id"                   .== autoModerationActionExecuteInfoUserId
    , "channel_id"                .=? autoModerationActionExecuteInfoChannelId
    , "message_id"                .=? autoModerationActionExecuteInfoMessageId
    , "alert_system_message_id"   .=? autoModerationActionExecuteInfoAlertMessageId
    , "content"                   .== autoModerationActionExecuteInfoContent
    , "matched_keyword"           .=? autoModerationActionExecuteInfoMatchedKeyword
    , "matched_content"           .=? autoModerationActionExecuteInfoMatchedContent
    ]

-- | Convert ToJSON value to FromJSON value
reparse :: (ToJSON a, FromJSON b) => a -> Parser b
reparse val = case parseEither parseJSON $ toJSON val of
                Left r -> fail r
                Right b -> pure b

-- | Remove the "wss://" and the trailing slash in a gateway URL, thereby returning
-- the hostname portion of the URL that we can connect to.
extractHostname :: String -> HostName
extractHostname ('w':'s':'s':':':'/':'/':rest) = extractHostname rest
extractHostname "/" = []
extractHostname (a:b) = a:extractHostname b
extractHostname [] = []

-- | Parse an event from name and JSON data
eventParse :: T.Text -> Object -> Parser EventInternalParse
eventParse t o = case t of
    "READY"                     -> InternalReady <$> o .: "v"
                                         <*> o .: "user"
                                         <*> o .: "guilds"
                                         <*> o .: "session_id"
                                          -- Discord can send us the resume gateway URL prefixed with "wss://",
                                          -- and suffixed with a trailing slash. This is not a valid HostName,
                                          -- so remove them both if they exist.
                                         <*> (extractHostname <$> o .: "resume_gateway_url")
                                         <*> o .: "shard"
                                         <*> o .: "application"
    "RESUMED"                   -> InternalResumed <$> o .: "_trace"
    "AUTO_MODERATION_RULE_CREATE" -> InternalAutoModerationRuleCreate <$> reparse o
    "AUTO_MODERATION_RULE_UPDATE" -> InternalAutoModerationRuleUpdate <$> reparse o
    "AUTO_MODERATION_RULE_DELETE" -> InternalAutoModerationRuleDelete <$> reparse o
    "AUTO_MODERATION_ACTION_EXECUTION" -> InternalAutoModerationActionExecution <$> reparse o
    "CHANNEL_CREATE"            -> InternalChannelCreate             <$> reparse o
    "CHANNEL_UPDATE"            -> InternalChannelUpdate             <$> reparse o
    "CHANNEL_DELETE"            -> InternalChannelDelete             <$> reparse o
    "THREAD_CREATE"             -> InternalThreadCreate              <$> reparse o
    "THREAD_UPDATE"             -> InternalThreadUpdate              <$> reparse o
    "THREAD_MEMBER_UPDATE"      -> InternalThreadMemberUpdate        <$> reparse o
    "THREAD_DELETE"             -> InternalThreadDelete              <$> reparse o
    "THREAD_LIST_SYNC"          -> InternalThreadListSync            <$> reparse o
    "THREAD_MEMBERS_UPDATE"     -> InternalThreadMembersUpdate       <$> reparse o
    "CHANNEL_PINS_UPDATE"       -> do id <- o .: "channel_id"
                                      stamp <- o .:? "last_pin_timestamp"
                                      let utc = stamp >>= parseISO8601
                                      pure (InternalChannelPinsUpdate id utc)
    "GUILD_CREATE"              -> parseGuildCreate o
    "GUILD_UPDATE"              -> InternalGuildUpdate               <$> reparse o
    "GUILD_DELETE"              -> InternalGuildDelete               <$> reparse o
    "GUILD_AUDIT_LOG_ENTRY_CREATE" -> InternalGuildAuditLogEntryCreate <$> reparse o
    "GUILD_BAN_ADD"             -> InternalGuildBanAdd    <$> o .: "guild_id" <*> o .: "user"
    "GUILD_BAN_REMOVE"          -> InternalGuildBanRemove <$> o .: "guild_id" <*> o .: "user"
    "GUILD_EMOJI_UPDATE"        -> InternalGuildEmojiUpdate <$> o .: "guild_id" <*> o .: "emojis"
    "GUILD_INTEGRATIONS_UPDATE" -> InternalGuildIntegrationsUpdate   <$> o .: "guild_id"
    "GUILD_MEMBER_ADD"          -> InternalGuildMemberAdd <$> o .: "guild_id" <*> reparse o
    "GUILD_MEMBER_REMOVE"       -> InternalGuildMemberRemove <$> o .: "guild_id" <*> o .: "user"
    "GUILD_MEMBER_UPDATE"       -> InternalGuildMemberUpdate <$> o .: "guild_id"
                                                             <*> o .: "roles"
                                                             <*> o .: "user"
                                                             <*> o .:? "nick"
    "GUILD_MEMBERS_CHUNK"       -> InternalGuildMemberChunk <$> o .: "guild_id" <*> o .: "members"
    "GUILD_ROLE_CREATE"         -> InternalGuildRoleCreate  <$> o .: "guild_id" <*> o .: "role"
    "GUILD_ROLE_UPDATE"         -> InternalGuildRoleUpdate  <$> o .: "guild_id" <*> o .: "role"
    "GUILD_ROLE_DELETE"         -> InternalGuildRoleDelete  <$> o .: "guild_id" <*> o .: "role_id"
    "MESSAGE_CREATE"            -> InternalMessageCreate     <$> reparse o
    "MESSAGE_UPDATE"            -> InternalMessageUpdate     <$> o .: "channel_id" <*> o .: "id"
    "MESSAGE_DELETE"            -> InternalMessageDelete     <$> o .: "channel_id" <*> o .: "id"
    "MESSAGE_DELETE_BULK"       -> InternalMessageDeleteBulk <$> o .: "channel_id" <*> o .: "ids"
    "MESSAGE_REACTION_ADD"      -> InternalMessageReactionAdd <$> reparse o
    "MESSAGE_REACTION_REMOVE"   -> InternalMessageReactionRemove <$> reparse o
    "MESSAGE_REACTION_REMOVE_ALL" -> InternalMessageReactionRemoveAll <$> o .: "channel_id"
                                                                      <*> o .: "message_id"
    "MESSAGE_REACTION_REMOVE_EMOJI" -> InternalMessageReactionRemoveEmoji <$> reparse o
    "PRESENCE_UPDATE"           -> InternalPresenceUpdate            <$> reparse o
    "TYPING_START"              -> InternalTypingStart               <$> reparse o
    "USER_UPDATE"               -> InternalUserUpdate                <$> reparse o
 -- "VOICE_STATE_UPDATE"        -> InternalVoiceStateUpdate          <$> reparse o
 -- "VOICE_SERVER_UPDATE"       -> InternalVoiceServerUpdate         <$> reparse o
    "INTERACTION_CREATE"        -> InternalInteractionCreate         <$> reparse o
    _other_event                -> InternalUnknownEvent t            <$> reparse o
