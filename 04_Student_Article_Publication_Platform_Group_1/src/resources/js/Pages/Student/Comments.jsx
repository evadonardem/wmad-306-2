import { useState, useEffect } from 'react';
import {
    Box,
    Typography,
    List,
    ListItem,
    TextField,
    Button,
    Avatar,
    CircularProgress,
    Alert,
    Snackbar,
    IconButton,
    Menu,
    MenuItem
} from '@mui/material';
import { Send, Edit, Delete, MoreVert, Reply } from '@mui/icons-material';

export default function Comments({ 
    articleId,
    currentUser = 'You',
    placeholder = "Add a comment...",
    showAvatar = true,
    onCommentsChange, // Callback to notify parent of comment count changes
    onNewComment // Callback to notify parent of new comment for real-time updates
}) {
    const [comments, setComments] = useState([]);
    const [commentText, setCommentText] = useState('');
    const [loading, setLoading] = useState(true);
    const [submitting, setSubmitting] = useState(false);
    const [error, setError] = useState(null);
    const [snackbar, setSnackbar] = useState({ open: false, message: '', severity: 'success' });
    const [editingComment, setEditingComment] = useState(null);
    const [editText, setEditText] = useState('');
    const [commentMenuAnchor, setCommentMenuAnchor] = useState(null);
    const [selectedCommentForMenu, setSelectedCommentForMenu] = useState(null);
    const [replyingTo, setReplyingTo] = useState(null); // ID of comment being replied to
    const [replyText, setReplyText] = useState('');

    // Load comments from localStorage on component mount
    useEffect(() => {
        loadComments();
    }, [articleId]);

    // Listen for storage changes to sync comments across components
    useEffect(() => {
        const handleStorageChange = (e) => {
            if (e.key === `article_comments_${articleId}` && e.newValue) {
                // Reload comments when they're updated from another component
                loadComments();
            }
        };

        // Listen for custom comment update events within the same page
        const handleCommentUpdate = (e) => {
            if (e.detail && e.detail.articleId === articleId) {
                if (e.detail.type === 'reply') {
                    // Handle real-time reply updates
                    const { newReply } = e.detail;
                    setComments(prevComments => 
                        prevComments.map(comment => {
                            if (comment.id === newReply.parentId) {
                                return {
                                    ...comment,
                                    replies: [...(comment.replies || []), newReply]
                                };
                            }
                            return comment;
                        })
                    );
                } else {
                    // Handle new comments
                    loadComments();
                }
            }
        };

        window.addEventListener('storage', handleStorageChange);
        window.addEventListener('commentUpdated', handleCommentUpdate);
        
        return () => {
            window.removeEventListener('storage', handleStorageChange);
            window.removeEventListener('commentUpdated', handleCommentUpdate);
        };
    }, [articleId]);

    // Save comments to localStorage whenever they change
    useEffect(() => {
        if (comments.length > 0 || !loading) {
            saveComments();
        }
        // Notify parent of comment count changes
        if (onCommentsChange) {
            onCommentsChange(comments.length);
        }
    }, [comments, loading]);

    const loadComments = () => {
        try {
            setLoading(true);
            setError(null);
            
            // Load comments from localStorage
            const storageKey = `article_comments_${articleId}`;
            const storedComments = localStorage.getItem(storageKey);
            
            if (storedComments) {
                const parsedComments = JSON.parse(storedComments);
                // Ensure all comments have replies arrays for backward compatibility
                const commentsWithReplies = parsedComments.map(comment => ({
                    ...comment,
                    replies: comment.replies || []
                }));
                setComments(commentsWithReplies);
            } else {
                setComments([]);
            }
        } catch (err) {
            console.error('Error loading comments from localStorage:', err);
            setError('Failed to load comments. Please try again.');
            showSnackbar('Failed to load comments', 'error');
        } finally {
            setLoading(false);
        }
    };

    const saveComments = () => {
        try {
            const storageKey = `article_comments_${articleId}`;
            localStorage.setItem(storageKey, JSON.stringify(comments));
        } catch (err) {
            console.error('Error saving comments to localStorage:', err);
        }
    };

    const handleSubmit = () => {
        if (!commentText.trim()) return;

        try {
            setSubmitting(true);
            setError(null);

            // Create new comment with unique ID and enhanced timestamp
            const now = new Date();
            const newComment = {
                id: Date.now(), // Unique ID using timestamp
                text: commentText.trim(),
                author: currentUser,
                timestamp: now.toISOString(),
                date: now.toLocaleDateString('en-US', {
                    month: 'numeric',
                    day: 'numeric', 
                    year: 'numeric',
                    hour: '2-digit',
                    minute: '2-digit',
                    second: '2-digit',
                    hour12: false
                }).replace(',', ''),
                replies: [] // Initialize with empty replies array
            };

            // Add new comment to the beginning of the list
            const updatedComments = [newComment, ...comments];
            setComments(updatedComments);
            setCommentText('');
            
            // Save to localStorage immediately
            const storageKey = `article_comments_${articleId}`;
            localStorage.setItem(storageKey, JSON.stringify(updatedComments));
            
            // Notify parent of new comment for real-time updates
            if (onNewComment) {
                onNewComment(newComment);
            }
            
            // Dispatch custom event to notify other Comments components of the update
            window.dispatchEvent(new CustomEvent('commentUpdated', {
                detail: { articleId, newComment }
            }));
            
            showSnackbar('Comment posted successfully!', 'success');
            
        } catch (err) {
            console.error('Error posting comment:', err);
            setError('Failed to post comment. Please try again.');
            showSnackbar('Failed to post comment', 'error');
        } finally {
            setSubmitting(false);
        }
    };

    const handleKeyPress = (e) => {
        if (e.key === 'Enter' && !e.shiftKey) {
            e.preventDefault();
            handleSubmit();
        }
    };

    const handleReplySubmit = (parentCommentId) => {
        if (!replyText.trim()) return;

        try {
            // Create new reply
            const newReply = {
                id: Date.now(), // Unique ID using timestamp
                text: replyText.trim(),
                author: 'Other User', // Simulate other user replying
                timestamp: new Date().toISOString(),
                date: new Date().toLocaleDateString(),
                parentId: parentCommentId
            };

            // Update comments with the new reply
            const updatedComments = comments.map(comment => {
                if (comment.id === parentCommentId) {
                    return {
                        ...comment,
                        replies: [...(comment.replies || []), newReply]
                    };
                }
                return comment;
            });

            setComments(updatedComments);
            setReplyText('');
            setReplyingTo(null);
            
            // Save to localStorage immediately
            const storageKey = `article_comments_${articleId}`;
            localStorage.setItem(storageKey, JSON.stringify(updatedComments));
            
            // Dispatch custom event for real-time updates
            window.dispatchEvent(new CustomEvent('commentUpdated', { 
                detail: { 
                    articleId, 
                    newReply,
                    type: 'reply'
                } 
            }));

            showSnackbar('Reply posted successfully!', 'success');
            
        } catch (err) {
            console.error('Error posting reply:', err);
            setError('Failed to post reply. Please try again.');
            showSnackbar('Failed to post reply', 'error');
        }
    };

    const handleReplyKeyPress = (e, parentCommentId) => {
        if (e.key === 'Enter' && !e.shiftKey) {
            e.preventDefault();
            handleReplySubmit(parentCommentId);
        }
    };

    const startReply = (commentId) => {
        setReplyingTo(commentId);
        setReplyText('');
    };

    const cancelReply = () => {
        setReplyingTo(null);
        setReplyText('');
    };

    const showSnackbar = (message, severity = 'success') => {
        setSnackbar({ open: true, message, severity });
    };

    const handleCloseSnackbar = () => {
        setSnackbar(prev => ({ ...prev, open: false }));
    };

    // Comment menu handlers
    const handleCommentMenuOpen = (event, comment) => {
        setCommentMenuAnchor(event.currentTarget);
        setSelectedCommentForMenu(comment);
    };

    const handleCommentMenuClose = () => {
        setCommentMenuAnchor(null);
        setSelectedCommentForMenu(null);
    };

    const handleEditComment = () => {
        if (selectedCommentForMenu) {
            setEditingComment(selectedCommentForMenu.id);
            setEditText(selectedCommentForMenu.text);
        }
        handleCommentMenuClose();
    };

    const handleDeleteComment = () => {
        if (selectedCommentForMenu) {
            try {
                const updatedComments = comments.filter(comment => comment.id !== selectedCommentForMenu.id);
                setComments(updatedComments);
                
                // Save to localStorage immediately
                const storageKey = `article_comments_${articleId}`;
                localStorage.setItem(storageKey, JSON.stringify(updatedComments));
                
                // Notify parent of comment count change
                if (onCommentsChange) {
                    onCommentsChange(updatedComments.length);
                }
                
                // Dispatch custom event to notify other Comments components
                window.dispatchEvent(new CustomEvent('commentUpdated', {
                    detail: { articleId, deletedComment: selectedCommentForMenu }
                }));
                
                showSnackbar('Comment deleted successfully!', 'success');
            } catch (err) {
                console.error('Error deleting comment:', err);
                setError('Failed to delete comment. Please try again.');
                showSnackbar('Failed to delete comment', 'error');
            }
        }
        handleCommentMenuClose();
    };

    const handleSaveEdit = () => {
        if (!editingComment || !editText.trim()) return;

        try {
            const updatedComments = comments.map(comment => {
                if (comment.id === editingComment) {
                    return {
                        ...comment,
                        text: editText.trim(),
                        edited: true,
                        editedAt: new Date().toISOString()
                    };
                }
                return comment;
            });
            
            setComments(updatedComments);
            setEditingComment(null);
            setEditText('');
            
            // Save to localStorage immediately
            const storageKey = `article_comments_${articleId}`;
            localStorage.setItem(storageKey, JSON.stringify(updatedComments));
            
            // Dispatch custom event to notify other Comments components
            window.dispatchEvent(new CustomEvent('commentUpdated', {
                detail: { articleId, editedComment: { id: editingComment, text: editText.trim() } }
            }));
            
            showSnackbar('Comment updated successfully!', 'success');
        } catch (err) {
            console.error('Error updating comment:', err);
            setError('Failed to update comment. Please try again.');
            showSnackbar('Failed to update comment', 'error');
        }
    };

    const handleCancelEdit = () => {
        setEditingComment(null);
        setEditText('');
    };

    return (
        <>
            <Box sx={{ mb: 2 }}>
                <Typography variant="subtitle2" sx={{ mb: 2, fontWeight: 'bold' }}>
                    Comments ({comments.length})
                </Typography>

                {/* Error Display */}
                {error && (
                    <Alert severity="error" sx={{ mb: 2 }} onClose={() => setError(null)}>
                        {error}
                    </Alert>
                )}

                {/* Loading State */}
                {loading ? (
                    <Box sx={{ display: 'flex', justifyContent: 'center', py: 4 }}>
                        <CircularProgress size={24} />
                        <Typography variant="body2" sx={{ ml: 2, color: 'text.secondary' }}>
                            Loading comments...
                        </Typography>
                    </Box>
                ) : (
                    <>
                        {/* Existing Comments */}
                        <List dense sx={{ mb: 2 }}>
                            {comments.length > 0 ? (
                                comments.map((comment) => (
                                    <ListItem key={comment.id} disableGutters>
                                        <Box sx={{ width: '100%' }}>
                                            <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start' }}>
                                                <Box sx={{ display: 'flex', alignItems: 'center', gap: 1 }}>
                                                    {showAvatar && (
                                                        <Avatar sx={{ 
                                                            width: 24, 
                                                            height: 24, 
                                                            fontSize: '0.75rem',
                                                            bgcolor: 'primary.main' 
                                                        }}>
                                                            {comment.author?.charAt(0)?.toUpperCase() || 'U'}
                                                        </Avatar>
                                                    )}
                                                    <Typography variant="body2" sx={{ fontWeight: 'bold' }}>
                                                        {comment.author}
                                                    </Typography>
                                                    {comment.edited && (
                                                        <Typography variant="caption" color="text.secondary" sx={{ ml: 1 }}>
                                                            (edited)
                                                        </Typography>
                                                    )}
                                                </Box>
                                                <Box sx={{ display: 'flex', alignItems: 'center', gap: 1 }}>
                                                    <Typography variant="caption" color="text.secondary">
                                                        {comment.date}
                                                    </Typography>
                                                    <IconButton
                                                        size="small"
                                                        onClick={() => startReply(comment.id)}
                                                        sx={{ 
                                                            p: 0.5,
                                                            '&:hover': {
                                                                backgroundColor: 'action.hover'
                                                            }
                                                        }}
                                                    >
                                                        <Reply fontSize="small" />
                                                    </IconButton>
                                                    {comment.author === currentUser && (
                                                        <IconButton
                                                            size="small"
                                                            onClick={(e) => handleCommentMenuOpen(e, comment)}
                                                            sx={{ 
                                                                p: 0.5,
                                                                '&:hover': {
                                                                    backgroundColor: 'action.hover'
                                                                }
                                                            }}
                                                        >
                                                            <MoreVert fontSize="small" />
                                                        </IconButton>
                                                    )}
                                                </Box>
                                            </Box>
                                            <Box sx={{ ml: showAvatar ? 3.5 : 0 }}>
                                                {editingComment === comment.id ? (
                                                    <Box sx={{ display: 'flex', flexDirection: 'column', gap: 1 }}>
                                                        <TextField
                                                            fullWidth
                                                            size="small"
                                                            multiline
                                                            rows={2}
                                                            value={editText}
                                                            onChange={(e) => setEditText(e.target.value)}
                                                            onKeyPress={(e) => {
                                                                if (e.key === 'Enter' && e.ctrlKey) {
                                                                    e.preventDefault();
                                                                    handleSaveEdit();
                                                                }
                                                            }}
                                                            sx={{
                                                                '& .MuiOutlinedInput-notchedOutline': {
                                                                    border: 'none',
                                                                },
                                                                '& .MuiOutlinedInput-root': {
                                                                    '&.Mui-focused fieldset': {
                                                                        border: 'none',
                                                                    },
                                                                    '&:hover fieldset': {
                                                                        border: 'none',
                                                                    },
                                                                    fieldset: {
                                                                        border: 'none',
                                                                    },
                                                                },
                                                            }}
                                                        />
                                                        <Box sx={{ display: 'flex', gap: 1, justifyContent: 'flex-end' }}>
                                                            <Button size="small" onClick={handleCancelEdit}>
                                                                Cancel
                                                            </Button>
                                                            <Button 
                                                                size="small" 
                                                                variant="contained" 
                                                                onClick={handleSaveEdit}
                                                                disabled={!editText.trim()}
                                                            >
                                                                Save
                                                            </Button>
                                                        </Box>
                                                    </Box>
                                                ) : (
                                                    <Typography variant="body2" color="text.secondary">
                                                        {comment.text}
                                                    </Typography>
                                                )}
                                                
                                                {/* Replies Section */}
                                                {comment.replies && comment.replies.length > 0 && (
                                                    <Box sx={{ mt: 2, ml: 2 }}>
                                                        <Typography variant="caption" sx={{ fontWeight: 'bold', color: 'text.secondary', mb: 1, display: 'block' }}>
                                                            {comment.replies.length} {comment.replies.length === 1 ? 'Reply' : 'Replies'}
                                                        </Typography>
                                                        {comment.replies.map((reply) => (
                                                            <Box key={reply.id} sx={{ 
                                                                mb: 1, 
                                                                p: 1, 
                                                                backgroundColor: 'grey.50', 
                                                                borderRadius: 1,
                                                                borderLeft: '2px solid',
                                                                borderLeftColor: 'primary.light'
                                                            }}>
                                                                <Box sx={{ display: 'flex', alignItems: 'center', gap: 1, mb: 0.5 }}>
                                                                    {showAvatar && (
                                                                        <Avatar sx={{ 
                                                                            width: 20, 
                                                                            height: 20, 
                                                                            fontSize: '0.6rem',
                                                                            bgcolor: 'secondary.main' 
                                                                        }}>
                                                                            {reply.author?.charAt(0)?.toUpperCase() || 'U'}
                                                                        </Avatar>
                                                                    )}
                                                                    <Typography variant="caption" sx={{ fontWeight: 'bold' }}>
                                                                        {reply.author}
                                                                    </Typography>
                                                                    <Typography variant="caption" color="text.secondary">
                                                                        {reply.date}
                                                                    </Typography>
                                                                </Box>
                                                                <Typography variant="caption" color="text.secondary" sx={{ ml: showAvatar ? 2.5 : 0 }}>
                                                                    {reply.text}
                                                                </Typography>
                                                            </Box>
                                                        ))}
                                                    </Box>
                                                )}
                                                
                                                {/* Reply Input */}
                                                {replyingTo === comment.id && (
                                                    <Box sx={{ mt: 2, ml: 2 }}>
                                                        <Box sx={{ display: 'flex', gap: 1, alignItems: 'flex-start' }}>
                                                            {showAvatar && (
                                                                <Avatar sx={{ 
                                                                    width: 24, 
                                                                    height: 24, 
                                                                    fontSize: '0.75rem',
                                                                    bgcolor: 'secondary.main',
                                                                    mt: 0.5
                                                                }}>
                                                                    O
                                                                </Avatar>
                                                            )}
                                                            <Box sx={{ flex: 1 }}>
                                                                <TextField
                                                                    fullWidth
                                                                    size="small"
                                                                    multiline
                                                                    rows={2}
                                                                    placeholder="Write a reply..."
                                                                    value={replyText}
                                                                    onChange={(e) => setReplyText(e.target.value)}
                                                                    onKeyPress={(e) => handleReplyKeyPress(e, comment.id)}
                                                                    sx={{
                                                                        '& .MuiOutlinedInput-notchedOutline': {
                                                                            border: 'none',
                                                                        },
                                                                        '& .MuiOutlinedInput-root': {
                                                                            '&.Mui-focused fieldset': {
                                                                                border: 'none',
                                                                            },
                                                                            '&:hover fieldset': {
                                                                                border: 'none',
                                                                            },
                                                                            fieldset: {
                                                                                border: 'none',
                                                                            },
                                                                        },
                                                                    }}
                                                                />
                                                                <Box sx={{ display: 'flex', gap: 1, justifyContent: 'flex-end', mt: 1 }}>
                                                                    <Button size="small" onClick={cancelReply}>
                                                                        Cancel
                                                                    </Button>
                                                                    <Button 
                                                                        size="small" 
                                                                        variant="contained" 
                                                                        onClick={() => handleReplySubmit(comment.id)}
                                                                        disabled={!replyText.trim()}
                                                                    >
                                                                        Reply
                                                                    </Button>
                                                                </Box>
                                                            </Box>
                                                        </Box>
                                                    </Box>
                                                )}
                                            </Box>
                                        </Box>
                                    </ListItem>
                                ))
                            ) : (
                                <Box sx={{ textAlign: 'center', py: 3, color: 'text.secondary' }}>
                                    <Typography variant="body2">
                                        No comments yet. Be the first to comment!
                                    </Typography>
                                </Box>
                            )}
                        </List>
                    </>
                )}

                {/* Add Comment */}
                <Box sx={{ display: 'flex', gap: 1, alignItems: 'flex-start' }}>
                    {showAvatar && (
                        <Avatar sx={{ 
                            width: 32, 
                            height: 32, 
                            fontSize: '0.875rem',
                            bgcolor: 'primary.main',
                            mt: 0.5
                        }}>
                            {currentUser.charAt(0).toUpperCase()}
                        </Avatar>
                    )}
                    <Box sx={{ flex: 1, display: 'flex', gap: 1 }}>
                        <TextField
                            fullWidth
                            size="small"
                            placeholder={placeholder}
                            value={commentText}
                            onChange={(e) => setCommentText(e.target.value)}
                            onKeyPress={handleKeyPress}
                            multiline
                            rows={2}
                            disabled={submitting}
                            sx={{
                                '& .MuiOutlinedInput-notchedOutline': {
                                    border: 'none',
                                },
                                '& .MuiOutlinedInput-root': {
                                    '&.Mui-focused fieldset': {
                                        border: 'none',
                                    },
                                    '&:hover fieldset': {
                                        border: 'none',
                                    },
                                    fieldset: {
                                        border: 'none',
                                    },
                                },
                            }}
                        />
                        <Button
                            variant="contained"
                            startIcon={submitting ? <CircularProgress size={16} /> : <Send />}
                            onClick={handleSubmit}
                            disabled={submitting || !commentText.trim()}
                            sx={{ 
                                alignSelf: 'flex-end',
                                borderRadius: 2,
                                minWidth: 'auto',
                                px: 2
                            }}
                        >
                            {submitting ? 'Posting...' : 'Post'}
                        </Button>
                    </Box>
                </Box>
            </Box>

            {/* Comment Menu */}
            <Menu
                anchorEl={commentMenuAnchor}
                open={Boolean(commentMenuAnchor)}
                onClose={handleCommentMenuClose}
                anchorOrigin={{
                    vertical: 'bottom',
                    horizontal: 'right',
                }}
                transformOrigin={{
                    vertical: 'top',
                    horizontal: 'right',
                }}
            >
                <MenuItem onClick={handleEditComment}>
                    <Edit fontSize="small" sx={{ mr: 1 }} />
                    Edit
                </MenuItem>
                <MenuItem onClick={handleDeleteComment} sx={{ color: 'error.main' }}>
                    <Delete fontSize="small" sx={{ mr: 1 }} />
                    Delete
                </MenuItem>
            </Menu>

            {/* Success/Error Snackbar */}
            <Snackbar
                open={snackbar.open}
                autoHideDuration={6000}
                onClose={handleCloseSnackbar}
                anchorOrigin={{ vertical: 'bottom', horizontal: 'center' }}
            >
                <Alert 
                    onClose={handleCloseSnackbar} 
                    severity={snackbar.severity}
                    sx={{ width: '100%' }}
                >
                    {snackbar.message}
                </Alert>
            </Snackbar>
        </>
    );
}