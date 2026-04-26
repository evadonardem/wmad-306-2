import React from 'react';
import {
    Dialog,
    DialogActions,
    DialogContent,
    DialogContentText,
    DialogTitle,
    Button,
} from '@mui/material';

const ConfirmationDialog = ({ open, onClose, onConfirm, title, message, confirmText = "Confirm", cancelText = "Cancel" }) => {
    return (
        <Dialog
            open={open}
            onClose={onClose}
            aria-labelledby="confirm-dialog-title"
            aria-describedby="confirm-dialog-description"
            PaperProps={{
                sx: {
                    borderRadius: 2,
                    minWidth: 300,
                }
            }}
        >
            <DialogTitle id="confirm-dialog-title" sx={{ typography: 'h6' }}>
                {title}
            </DialogTitle>
            <DialogContent>
                <DialogContentText id="confirm-dialog-description" sx={{ typography: 'body1' }}>
                    {message}
                </DialogContentText>
            </DialogContent>
            <DialogActions sx={{ p: 3, pt: 0 }}>
                <Button onClick={onClose} color="inherit">
                    {cancelText}
                </Button>
                <Button onClick={onConfirm} variant="contained" color="primary" autoFocus>
                    {confirmText}
                </Button>
            </DialogActions>
        </Dialog>
    );
};

export default ConfirmationDialog;
