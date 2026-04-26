import { Button, ButtonGroup } from '@mui/material';

export default function ActionButtonGroup({ actions = [], variant = 'contained', sx, ...props }) {
    return (
        <ButtonGroup
            variant={variant}
            aria-label="Action button group"
            sx={{
                borderRadius: 999,
                overflow: 'hidden',
                '& .MuiButton-root': {
                    px: 2.25,
                    fontWeight: 700,
                },
                ...sx,
            }}
            {...props}
        >
            {actions.map(({ label, key, ...buttonProps }, index) => (
                <Button key={key ?? `${label}-${index}`} {...buttonProps}>
                    {label}
                </Button>
            ))}
        </ButtonGroup>
    );
}
