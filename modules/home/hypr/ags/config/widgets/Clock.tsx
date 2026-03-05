import { createPoll } from "ags/time"

export default function Clock() {
  const time = createPoll("", 1000, "date '+%b %d  %I:%M %p'")

  return (
    <box cssClasses={["clock"]}>
      <label label={time} />
    </box>
  )
}
