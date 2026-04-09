import { execAsync, GLib } from "astal"

export const HOME = GLib.get_home_dir()
export const CONFIG = `${HOME}/.config`
export const CACHE = `${HOME}/.cache`

export async function sh(cmd: string): Promise<string> {
    return execAsync(["bash", "-c", cmd])
}

export function range(length: number, start = 0): number[] {
    return Array.from({ length }, (_, i) => i + start)
}

export function dependencies(...bins: string[]): boolean {
    const missing = bins.filter(bin => {
        try {
            GLib.find_program_in_path(bin)
            return false
        } catch {
            return true
        }
    })

    if (missing.length > 0) {
        console.error(`Missing dependencies: ${missing.join(", ")}`)
        return false
    }

    return true
}
