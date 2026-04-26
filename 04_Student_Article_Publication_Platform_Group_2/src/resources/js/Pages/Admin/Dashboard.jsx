import { Head, router } from '@inertiajs/react';
import AuthenticatedLayout from '@/Layouts/AuthenticatedLayout';
import {
    Box,
    Container,
    Typography,
    Card,
    CardContent,
    Table,
    TableBody,
    TableCell,
    TableContainer,
    TableHead,
    TableRow,
    Paper,
    Chip,
    Snackbar,
    Alert,
    Checkbox,
    FormGroup,
    FormControlLabel,
    Stack,
    Grid,
    LinearProgress,
    Divider,
    Pagination,
} from '@mui/material';
import {
    People as PeopleIcon,
    AdminPanelSettings as AdminIcon,
    Edit as EditorIcon,
    Create as WriterIcon,
    School as StudentIcon,
    Article as ArticleIcon,
    Forum as ForumIcon,
    AutoGraph as AutoGraphIcon,
} from '@mui/icons-material';
import { useState } from 'react';

export default function Dashboard({
    users,
    availableRoles,
    platformStats,
    roleDistribution,
    statusDistribution,
    recentPublishedArticles,
    recentComments,
}) {
    const [snackbar, setSnackbar] = useState({ open: false, message: '', severity: 'success' });

    const handleUsersPageChange = (_event, page) => {
        router.get(
            route('admin.dashboard'),
            { page },
            {
                preserveScroll: true,
                preserveState: true,
            }
        );
    };

    const handleRoleToggle = (userId, role, currentRoles) => {
        const newRoles = currentRoles.includes(role)
            ? currentRoles.filter((r) => r !== role)
            : [...currentRoles, role];

        // Ensure at least one role is selected
        if (newRoles.length === 0) {
            setSnackbar({
                open: true,
                message: 'User must have at least one role.',
                severity: 'warning',
            });
            return;
        }

        router.put(
            route('admin.users.update-roles', userId),
            { roles: newRoles },
            {
                preserveScroll: true,
                onSuccess: () => {
                    setSnackbar({
                        open: true,
                        message: 'User roles updated successfully!',
                        severity: 'success',
                    });
                },
                onError: () => {
                    setSnackbar({
                        open: true,
                        message: 'Failed to update user roles.',
                        severity: 'error',
                    });
                },
            }
        );
    };

    const getRoleColor = (role) => {
        const colors = {
            admin: 'error',
            editor: 'primary',
            writer: 'secondary',
            student: 'success',
            none: 'default',
        };
        return colors[role] || 'default';
    };

    const getRoleIcon = (role) => {
        const iconProps = { sx: { fontSize: 16 } };
        switch (role) {
            case 'admin':
                return <AdminIcon {...iconProps} />;
            case 'editor':
                return <EditorIcon {...iconProps} />;
            case 'writer':
                return <WriterIcon {...iconProps} />;
            case 'student':
                return <StudentIcon {...iconProps} />;
            default:
                return <PeopleIcon {...iconProps} />;
        }
    };

    const statusColors = {
        draft: '#64748B',
        submitted: '#0284C7',
        needs_revision: '#D97706',
        published: '#16A34A',
    };

    const maxRoleCount = Math.max(...roleDistribution.map((item) => item.count), 1);
    const maxStatusCount = Math.max(...statusDistribution.map((item) => item.count), 1);

    const statCards = [
        {
            title: 'Total Users',
            value: platformStats.totalUsers,
            subtitle: `${platformStats.multiRoleUsers} multi-role`,
            icon: <PeopleIcon sx={{ fontSize: 24 }} />,
            color: '#1D4ED8',
        },
        {
            title: 'Total Articles',
            value: platformStats.totalArticles,
            subtitle: `${platformStats.publishedArticles} published`,
            icon: <ArticleIcon sx={{ fontSize: 24 }} />,
            color: '#7C3AED',
        },
        {
            title: 'Total Comments',
            value: platformStats.totalComments,
            subtitle: 'Reader engagement',
            icon: <ForumIcon sx={{ fontSize: 24 }} />,
            color: '#0891B2',
        },
        {
            title: 'This Month',
            value: platformStats.newArticlesThisMonth,
            subtitle: `${platformStats.newUsersThisMonth} new users`,
            icon: <AutoGraphIcon sx={{ fontSize: 24 }} />,
            color: '#16A34A',
        },
    ];

    return (
        <AuthenticatedLayout
            header={
                <Box sx={{ display: 'flex', alignItems: 'center', gap: 2 }}>
                    <AdminIcon sx={{ fontSize: 32 }} />
                    <Typography variant="h4" component="h2">
                        Admin Dashboard
                    </Typography>
                </Box>
            }
        >
            <Head title="Admin Dashboard" />

            <Container maxWidth="lg" sx={{ mt: 4, mb: 4 }}>
                <Grid container spacing={2.5} sx={{ mb: 3 }}>
                    {statCards.map((card) => (
                        <Grid size={{ xs: 12, sm: 6, md: 3 }} key={card.title}>
                            <Card elevation={2}>
                                <CardContent>
                                    <Box sx={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
                                        <Box>
                                            <Typography variant="body2" color="text.secondary" sx={{ mb: 0.5 }}>
                                                {card.title}
                                            </Typography>
                                            <Typography variant="h4" sx={{ fontWeight: 800, lineHeight: 1 }}>
                                                {card.value}
                                            </Typography>
                                            <Typography variant="caption" color="text.secondary">
                                                {card.subtitle}
                                            </Typography>
                                        </Box>
                                        <Box
                                            sx={{
                                                width: 44,
                                                height: 44,
                                                borderRadius: 2,
                                                display: 'grid',
                                                placeItems: 'center',
                                                color: '#fff',
                                                bgcolor: card.color,
                                            }}
                                        >
                                            {card.icon}
                                        </Box>
                                    </Box>
                                </CardContent>
                            </Card>
                        </Grid>
                    ))}
                </Grid>

                <Grid container spacing={2.5} sx={{ mb: 3 }}>
                    <Grid size={{ xs: 12, md: 6 }}>
                        <Card elevation={2} sx={{ height: '100%' }}>
                            <CardContent>
                                <Typography variant="h6" sx={{ fontWeight: 700, mb: 2 }}>
                                    Role Distribution
                                </Typography>
                                <Stack spacing={1.5}>
                                    {roleDistribution.map((item) => (
                                        <Box key={item.role}>
                                            <Box sx={{ display: 'flex', justifyContent: 'space-between', mb: 0.5 }}>
                                                <Typography variant="body2" sx={{ textTransform: 'capitalize' }}>
                                                    {item.role}
                                                </Typography>
                                                <Typography variant="body2" sx={{ fontWeight: 700 }}>
                                                    {item.count}
                                                </Typography>
                                            </Box>
                                            <LinearProgress
                                                variant="determinate"
                                                value={(item.count / maxRoleCount) * 100}
                                                sx={{ height: 8, borderRadius: 2 }}
                                            />
                                        </Box>
                                    ))}
                                </Stack>
                            </CardContent>
                        </Card>
                    </Grid>

                    <Grid size={{ xs: 12, md: 6 }}>
                        <Card elevation={2} sx={{ height: '100%' }}>
                            <CardContent>
                                <Typography variant="h6" sx={{ fontWeight: 700, mb: 2 }}>
                                    Article Status Breakdown
                                </Typography>
                                <Stack spacing={1.5}>
                                    {statusDistribution.map((item) => (
                                        <Box key={item.status}>
                                            <Box sx={{ display: 'flex', justifyContent: 'space-between', mb: 0.5 }}>
                                                <Typography variant="body2" sx={{ textTransform: 'capitalize' }}>
                                                    {item.status.replace('_', ' ')}
                                                </Typography>
                                                <Typography variant="body2" sx={{ fontWeight: 700 }}>
                                                    {item.count}
                                                </Typography>
                                            </Box>
                                            <LinearProgress
                                                variant="determinate"
                                                value={(item.count / maxStatusCount) * 100}
                                                sx={{
                                                    height: 8,
                                                    borderRadius: 2,
                                                    '& .MuiLinearProgress-bar': {
                                                        bgcolor: statusColors[item.status] || '#64748B',
                                                    },
                                                }}
                                            />
                                        </Box>
                                    ))}
                                </Stack>
                            </CardContent>
                        </Card>
                    </Grid>
                </Grid>

                <Grid container spacing={2.5} sx={{ mb: 3 }}>
                    <Grid size={{ xs: 12, md: 6 }}>
                        <Card elevation={2} sx={{ height: '100%' }}>
                            <CardContent>
                                <Typography variant="h6" sx={{ fontWeight: 700, mb: 1.5 }}>
                                    Recent Published Articles
                                </Typography>
                                <Stack divider={<Divider />}>
                                    {recentPublishedArticles.length > 0 ? (
                                        recentPublishedArticles.map((article) => (
                                            <Box key={article.id} sx={{ py: 1.2 }}>
                                                <Typography variant="body2" sx={{ fontWeight: 700 }}>
                                                    {article.title}
                                                </Typography>
                                                <Typography variant="caption" color="text.secondary">
                                                    By {article.writer || 'Unknown'} • {new Date(article.published_at).toLocaleString()}
                                                </Typography>
                                            </Box>
                                        ))
                                    ) : (
                                        <Typography variant="body2" color="text.secondary" sx={{ py: 1.2 }}>
                                            No recent published articles.
                                        </Typography>
                                    )}
                                </Stack>
                            </CardContent>
                        </Card>
                    </Grid>

                    <Grid size={{ xs: 12, md: 6 }}>
                        <Card elevation={2} sx={{ height: '100%' }}>
                            <CardContent>
                                <Typography variant="h6" sx={{ fontWeight: 700, mb: 1.5 }}>
                                    Recent Comments
                                </Typography>
                                <Stack divider={<Divider />}>
                                    {recentComments.length > 0 ? (
                                        recentComments.map((comment) => (
                                            <Box key={comment.id} sx={{ py: 1.2 }}>
                                                <Typography variant="body2" sx={{ fontWeight: 700 }}>
                                                    {comment.student || 'Unknown User'} on {comment.article || 'Untitled'}
                                                </Typography>
                                                <Typography variant="caption" color="text.secondary" sx={{ display: 'block' }}>
                                                    {new Date(comment.created_at).toLocaleString()}
                                                </Typography>
                                                <Typography variant="body2" color="text.secondary" sx={{ mt: 0.5 }}>
                                                    {comment.content}
                                                </Typography>
                                            </Box>
                                        ))
                                    ) : (
                                        <Typography variant="body2" color="text.secondary" sx={{ py: 1.2 }}>
                                            No recent comments.
                                        </Typography>
                                    )}
                                </Stack>
                            </CardContent>
                        </Card>
                    </Grid>
                </Grid>

                <Card elevation={3}>
                    <CardContent>
                        <Box sx={{ display: 'flex', alignItems: 'center', mb: 3, gap: 2 }}>
                            <PeopleIcon sx={{ fontSize: 28, color: 'primary.main' }} />
                            <Typography variant="h5" component="h3">
                                User Management
                            </Typography>
                        </Box>

                        <Typography variant="body2" color="text.secondary" sx={{ mb: 3 }}>
                            Manage user roles and permissions. Users can have multiple roles. Use
                            checkboxes to assign or remove roles.
                        </Typography>

                        <TableContainer component={Paper} variant="outlined">
                            <Table>
                                <TableHead>
                                    <TableRow sx={{ bgcolor: 'grey.100' }}>
                                        <TableCell sx={{ fontWeight: 'bold' }}>Name</TableCell>
                                        <TableCell sx={{ fontWeight: 'bold' }}>Email</TableCell>
                                        <TableCell sx={{ fontWeight: 'bold' }}>Current Roles</TableCell>
                                        <TableCell sx={{ fontWeight: 'bold' }}>Manage Roles</TableCell>
                                    </TableRow>
                                </TableHead>
                                <TableBody>
                                    {users.data.map((user) => (
                                        <TableRow
                                            key={user.id}
                                            sx={{
                                                '&:hover': { bgcolor: 'grey.50' },
                                            }}
                                        >
                                            <TableCell>
                                                <Typography variant="body1" sx={{ fontWeight: 500 }}>
                                                    {user.name}
                                                </Typography>
                                            </TableCell>
                                            <TableCell>
                                                <Typography variant="body2" color="text.secondary">
                                                    {user.email}
                                                </Typography>
                                            </TableCell>
                                            <TableCell>
                                                <Stack direction="row" spacing={0.5} flexWrap="wrap" useFlexGap>
                                                    {user.roles.length > 0 ? (
                                                        user.roles.map((role) => (
                                                            <Chip
                                                                key={role}
                                                                icon={getRoleIcon(role)}
                                                                label={role}
                                                                color={getRoleColor(role)}
                                                                size="small"
                                                                sx={{ mb: 0.5 }}
                                                            />
                                                        ))
                                                    ) : (
                                                        <Chip
                                                            label="No roles"
                                                            size="small"
                                                            color="default"
                                                            variant="outlined"
                                                        />
                                                    )}
                                                </Stack>
                                            </TableCell>
                                            <TableCell>
                                                <FormGroup>
                                                    {availableRoles.map((role) => (
                                                        <FormControlLabel
                                                            key={role}
                                                            control={
                                                                <Checkbox
                                                                    checked={user.roles.includes(role)}
                                                                    onChange={() =>
                                                                        handleRoleToggle(
                                                                            user.id,
                                                                            role,
                                                                            user.roles
                                                                        )
                                                                    }
                                                                    size="small"
                                                                />
                                                            }
                                                            label={
                                                                <Box sx={{ display: 'flex', alignItems: 'center', gap: 0.5 }}>
                                                                    {getRoleIcon(role)}
                                                                    <Typography variant="body2">{role}</Typography>
                                                                </Box>
                                                            }
                                                        />
                                                    ))}
                                                </FormGroup>
                                            </TableCell>
                                        </TableRow>
                                    ))}
                                </TableBody>
                            </Table>
                        </TableContainer>

                        <Box sx={{ mt: 3, p: 2, bgcolor: 'info.lighter', borderRadius: 1 }}>
                            <Typography variant="body2" color="text.secondary">
                                <strong>Total Users:</strong> {users.total}
                            </Typography>
                        </Box>

                        {users.last_page > 1 && (
                            <Box sx={{ mt: 2.5, display: 'flex', justifyContent: 'center' }}>
                                <Pagination
                                    count={users.last_page}
                                    page={users.current_page}
                                    onChange={handleUsersPageChange}
                                    color="primary"
                                />
                            </Box>
                        )}
                    </CardContent>
                </Card>
            </Container>

            <Snackbar
                open={snackbar.open}
                autoHideDuration={4000}
                onClose={() => setSnackbar({ ...snackbar, open: false })}
                anchorOrigin={{ vertical: 'bottom', horizontal: 'right' }}
            >
                <Alert
                    onClose={() => setSnackbar({ ...snackbar, open: false })}
                    severity={snackbar.severity}
                    sx={{ width: '100%' }}
                >
                    {snackbar.message}
                </Alert>
            </Snackbar>
        </AuthenticatedLayout>
    );
}
