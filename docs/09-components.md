# Components (Buttons, Selects & Modals)

Components V2 is SWDCK's powerful system for building interactive UIs within Discord messages. This includes buttons, dropdown menus, and pop-up modals.

## Buttons

Buttons are the most common component. They can trigger an interaction or open a link.

```swift
let button = ComponentV2Button(
    style: .primary,
    label: "Click Me",
    customId: "my_button_id"
)

let actionRow = ComponentV2ActionRow(components: [.button(button)])
try await bot.sendComponentsV2Message(to: channelId, components: [.actionRow(actionRow)])
```

### Button Styles
| Style | Description |
|-------|-------------|
| `.primary` | Blurple (main action). |
| `.secondary` | Grey (secondary action). |
| `.success` | Green (positive outcome). |
| `.danger` | Red (destructive action). |
| `.link` | Grey with a link icon (requires a `url`). |

---

## Select Menus

Select menus allow users to choose from a list of options.

```swift
let select = ComponentV2StringSelect(
    customId: "color_picker",
    options: [
        ComponentV2SelectOption(label: "Red", value: "red"),
        ComponentV2SelectOption(label: "Blue", value: "blue")
    ],
    placeholder: "Choose a color"
)

let actionRow = ComponentV2ActionRow(components: [.stringSelect(select)])
try await bot.sendComponentsV2Message(to: channelId, components: [.actionRow(actionRow)])
```

---

## Handling Component Interactions

When a user clicks a button or selects an option, it triggers an interaction. Listen for these using `onInteraction`.

```swift
bot.onInteraction { interaction in
    guard interaction.type == .messageComponent else { return }
    
    if interaction.data?.customId == "my_button_id" {
        try await interaction.respond("You clicked the button!")
    }
}
```

---

## Modals

Modals are pop-up forms that can gather text input from the user.

### Presenting a Modal
Modals must be sent as a response to an interaction (e.g., a button click or a slash command).

```swift
bot.slashCommand("report", description: "Report an issue") { interaction in
    let input = ComponentV2TextInput(
        customId: "issue_desc",
        style: .paragraph,
        placeholder: "Describe the problem..."
    )
    
    let container = ComponentV2Label(
        label: "Issue Description",
        component: .textInput(input)
    )
    
    try await interaction.presentModal(
        customId: "report_modal",
        title: "Submit Report",
        components: [container]
    )
}
```

### Handling Modal Submission

```swift
bot.onInteraction { interaction in
    guard interaction.type == .modalSubmit else { return }
    
    if interaction.data?.customId == "report_modal" {
        let description = interaction.data?.submittedValue(customId: "issue_desc")?.stringValue
        try await interaction.respond("Thank you for your report: \(description ?? "N/A")", ephemeral: true)
    }
}
```

> **Next:** [Permissions & Roles](./permissions-roles)
