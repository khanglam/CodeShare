{
    "description": "Remap Command + Delete to Option + Delete",
    "manipulators": [
        {
            "type": "basic",
            "from": {
                "key_code": "delete_or_backspace",
                "modifiers": {
                    "mandatory": ["command"],
                    "optional": ["caps_lock"]
                }
            },
            "to": [
                {
                    "key_code": "delete_or_backspace",
                    "modifiers": ["left_option"]
                }
            ]
        }
    ]
}
