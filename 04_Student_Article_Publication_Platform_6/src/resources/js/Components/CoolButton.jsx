import { Button } from '@mui/material';

export default function CoolButton({ tone = 'primary', sx, children, ...props }) {
    const isOutline = tone === 'outline';

    return (
        <Button
            variant={isOutline ? 'outlined' : 'contained'}
            color="primary"
            sx={{
                borderRadius: 999,
                px: 2.25,
                py: 1,
                fontWeight: 700,
                ...(isOutline
                    ? {
                          backgroundColor: 'rgba(47, 111, 219, 0.03)',
                          borderColor: 'rgba(47, 111, 219, 0.45)',
                      }
                    : {
                          backgroundColor: '#2f6fdb',
                          '&:hover': { backgroundColor: '#2157b4' },
                      }),
                ...sx,
            }}
            {...props}
        >
            {children}
        </Button>
    );
}
