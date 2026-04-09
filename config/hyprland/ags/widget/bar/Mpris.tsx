import { bind } from "astal"
import Mpris from "gi://AstalMpris"

export default function MprisWidget() {
    const mpris = Mpris.get_default()

    return <box className="Mpris">
        {bind(mpris, "players").as(players => {
            const player = players[0]
            if (!player) return <box />

            return <box>
                <box className="cover" css={bind(player, "coverArt").as(c =>
                    `background-image: url('${c}');`
                )} />
                <box vertical>
                    <label className="title" truncate label={bind(player, "title")} />
                    <label className="artist" truncate label={bind(player, "artist")} />
                </box>
                <box className="controls">
                    <button onClicked={() => player.previous()}>
                        <icon icon="media-skip-backward-symbolic" />
                    </button>
                    <button onClicked={() => player.play_pause()}>
                        <icon icon={bind(player, "playbackStatus").as(s =>
                            s === Mpris.PlaybackStatus.PLAYING
                                ? "media-playback-pause-symbolic"
                                : "media-playback-start-symbolic"
                        )} />
                    </button>
                    <button onClicked={() => player.next()}>
                        <icon icon="media-skip-forward-symbolic" />
                    </button>
                </box>
            </box>
        })}
    </box>
}
