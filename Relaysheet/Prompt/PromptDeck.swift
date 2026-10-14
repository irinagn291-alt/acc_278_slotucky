import Foundation

/// Bundled two-beat deck. The same daykey always selects the same pair. No network.
enum PromptDeck {
    static let prompts: [Prompt] = [
        Prompt(id: "porch", partA: "What did the light look like when you got home?", partB: "What did you want to tell them first?"),
        Prompt(id: "table", partA: "Name one thing still on the table from yesterday.", partB: "What would you clear, and what would you keep?"),
        Prompt(id: "walk", partA: "Where did your feet take you today?", partB: "Where would you walk them next?"),
        Prompt(id: "quiet", partA: "What stayed quiet that usually does not?", partB: "What did that quiet make room for?"),
        Prompt(id: "hands", partA: "What did your hands finish today?", partB: "What do you want their hands to know?"),
        Prompt(id: "window", partA: "What was outside the window at dusk?", partB: "What did you hope they noticed too?"),
        Prompt(id: "meal", partA: "What did you actually eat, not what you planned?", partB: "What would you cook for them tomorrow?"),
        Prompt(id: "name", partA: "Who did you think of without meaning to?", partB: "What would you say if they walked in right now?")
    ]

    static func prompt(for daykey: Int) -> Prompt {
        let count = prompts.count
        let index = ((daykey % count) + count) % count
        return prompts[index]
    }
}
