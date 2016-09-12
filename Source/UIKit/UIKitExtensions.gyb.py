import_frameworks = ["UIKit"]
reusable_view_classes = ["UICollectionReusableView", "UITableViewHeaderFooterView", "UITableViewCell"]

extension_info = {
    "UIView": {
        "alpha": {"type": "CGFloat"},
        "isHidden": {"type": "Bool", "was": "hidden"},
        "isUserInteractionEnabled": {"type": "Bool", "was": "userInteractionEnabled"},
        "backgroundColor": {"type": "UIColor?"}
    },
    "UILabel": {
        "text": {"type": "String?"},
        "attributedText": {"type": "NSAttributedString?"},
        "textColor": {"type": "UIColor"}
    },
    "UIBarItem": {
        "isEnabled": {"type": "Bool", "was": "enabled"}
    },
    "UIControl": {
        "isEnabled": {"type": "Bool", "was": "enabled"},
        "isHighlighted": {"type": "Bool", "was": "highlighted"},
        "isSelected": {"type": "Bool", "was": "selected"}
    },
    "UIImageView": {
        "image": {"type": "UIImage?"},
        "highlightedImage": {"type": "UIImage?"}
    },
    "UIProgressView": {
        "progress": {"type": "Float"}
    }
}

if target == "iOS":
    extension_info.update({
        "UISwitch": {
            "isOn": {"isControl": True, "type": "Bool", "was": "on"}
        },
        "UIDatePicker": {
            "date": {"isControl": True, "type": "Date"}
        }
    })
