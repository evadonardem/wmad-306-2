import { Alert, Snackbar } from '@mui/material';
import { createContext, useContext, useState } from 'react';

const ToastContext = createContext(null);

export function ToastProvider({ children }) {
  const [open, setOpen] = useState(false);
  const [options, setOptions] = useState({ message: '', severity: 'info' });

  const showToast = (message, severity = 'success') => {
    setOptions({ message, severity });
    setOpen(true);
  };

  const handleClose = () => setOpen(false);

  return (
    <ToastContext.Provider value={{ showToast }}>
      {children}
      <Snackbar open={open} autoHideDuration={4000} onClose={handleClose} anchorOrigin={{ vertical: 'bottom', horizontal: 'center' }}>
        <Alert onClose={handleClose} severity={options.severity} sx={{ width: '100%' }}>
          {options.message}
        </Alert>
      </Snackbar>
    </ToastContext.Provider>
  );
}

export function useToast() {
  const ctx = useContext(ToastContext);
  if (!ctx) throw new Error('useToast must be used within ToastProvider');
  return ctx;
}

export default ToastProvider;
