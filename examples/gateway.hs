{-# LANGUAGE OverloadedStrings #-}

import Control.Monad (forever)
import UnliftIO (liftIO)
import UnliftIO.Concurrent
import qualified Data.Text.IO as TIO

import Discord.Types
import DiscordMonadTransformerLibrary

-- | Prints every event as it happens
gatewayExample :: IO ()
gatewayExample = do
  tok <- TIO.readFile "./examples/auth-token.secret"

  outChan <- newChan :: IO (Chan String)

  -- Events are processed in new threads, but stdout isn't
  -- synchronized. We get ugly output when multiple threads
  -- write to stdout at the same time
  threadId <- forkIO $ forever $ readChan outChan >>= putStrLn

  err <- runDiscord $ def { discordToken = tok
                          , discordOnStart = startHandler
                          , discordOnEvent = eventHandler outChan
                          , discordOnEnd = killThread threadId
                          }
  TIO.putStrLn err

-- Events are enumerated in the discord docs
-- https://discord.com/developers/docs/topics/gateway#commands-and-events-gateway-events
eventHandler :: Chan String -> Event -> DiscordHandler ()
eventHandler out event = liftIO $ writeChan out (show event <> "\n")


startHandler :: DiscordHandler ()
startHandler = do
  let opts = RequestGuildMembersOpts
        { requestGuildMembersOptsGuildId = 453207241294610442
        , requestGuildMembersOptsLimit = 100
        , requestGuildMembersOptsNamesStartingWith = ""
        }

  -- gateway commands are enumerated in the discord docs
  -- https://discord.com/developers/docs/topics/gateway#commands-and-events-gateway-commands
  sendCommand (RequestGuildMembers opts)


