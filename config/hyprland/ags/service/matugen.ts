import { execAsync, GLib } from "astal"
import { HOME, CACHE } from "../lib/utils"

export async function applyMatugen(imagePath: string): Promise<void> {
    try {
        await execAsync(["matugen", "image", imagePath])
        console.log(`Matugen applied colors from: ${imagePath}`)
    } catch (error) {
        console.error("Failed to apply matugen:", error)
    }
}

export function getCurrentWallpaper(): string | null {
    const wallPath = `${CACHE}/current_wallpaper`
    if (GLib.file_test(wallPath, GLib.FileTest.EXISTS)) {
        const [ok, contents] = GLib.file_get_contents(wallPath)
        if (ok) {
            return new TextDecoder().decode(contents).trim()
        }
    }
    return null
}
