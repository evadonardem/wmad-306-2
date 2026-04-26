import { Chip } from '@mui/material';
import { CalendarToday, Warning, Error } from '@mui/icons-material';

const DueDateChip = ({ dueDate, dueDateStatus }) => {
    if (!dueDate) {
        return null;
    }

    const getChipProps = () => {
        switch (dueDateStatus) {
            case 'overdue':
                return {
                    color: 'error',
                    icon: <Error sx={{ fontSize: 16 }} />,
                    label: `Overdue (${dueDate})`,
                };
            case 'due-today':
                return {
                    color: 'warning',
                    icon: <Warning sx={{ fontSize: 16 }} />,
                    label: `Due Today (${dueDate})`,
                };
            case 'due-soon':
                return {
                    color: 'warning',
                    icon: <Warning sx={{ fontSize: 16 }} />,
                    label: `Due Soon (${dueDate})`,
                };
            default:
                return {
                    color: 'default',
                    icon: <CalendarToday sx={{ fontSize: 16 }} />,
                    label: dueDate,
                };
        }
    };

    const chipProps = getChipProps();

    return (
        <Chip
            icon={chipProps.icon}
            label={chipProps.label}
            color={chipProps.color}
            size="small"
            variant="outlined"
            sx={{ fontWeight: 500 }}
        />
    );
};

export default DueDateChip;
