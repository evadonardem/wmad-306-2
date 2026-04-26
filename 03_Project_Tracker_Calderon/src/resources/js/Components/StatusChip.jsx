import { Chip } from '@mui/material';

const StatusChip = ({ status }) => {
    const getStatusColor = (status) => {
        switch (status) {
            case 'completed':
                return 'success';
            case 'on going':
                return 'info';
            case 'pending':
                return 'default';
            default:
                return 'default';
        }
    };

    const getStatusLabel = (status) => {
        switch (status) {
            case 'completed':
                return 'Completed';
            case 'on going':
                return 'On Going';
            case 'pending':
                return 'Pending';
            default:
                return status;
        }
    };

    return (
        <Chip
            label={getStatusLabel(status)}
            color={getStatusColor(status)}
            size="small"
            variant="outlined"
            sx={{ fontWeight: 500 }}
        />
    );
};

export default StatusChip;
