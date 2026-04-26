import React from 'react';
import {
    TextField,
    FormControl,
    InputLabel,
    Select,
    MenuItem,
    FormHelperText,
    Box,
    Typography
} from '@mui/material';

export const FormTextField = ({
    label,
    value,
    onChange,
    error,
    helperText,
    required = false,
    multiline = false,
    rows = 1,
    placeholder = '',
    type = 'text',
    disabled = false,
    fullWidth = true,
    ...props
}) => {
    return (
        <TextField
            label={label}
            value={value}
            onChange={onChange}
            error={!!error}
            helperText={error || helperText}
            required={required}
            multiline={multiline}
            rows={rows}
            placeholder={placeholder}
            type={type}
            disabled={disabled}
            fullWidth={fullWidth}
            variant="outlined"
            {...props}
        />
    );
};

export const FormSelect = ({
    label,
    value,
    onChange,
    error,
    helperText,
    required = false,
    disabled = false,
    fullWidth = true,
    children,
    ...props
}) => {
    return (
        <FormControl 
            fullWidth={fullWidth} 
            error={!!error} 
            required={required}
            disabled={disabled}
            variant="outlined"
        >
            <InputLabel>{label}</InputLabel>
            <Select
                value={value}
                label={label}
                onChange={onChange}
                {...props}
            >
                {children}
            </Select>
            {error && (
                <FormHelperText error>{error}</FormHelperText>
            )}
            {helperText && !error && (
                <FormHelperText>{helperText}</FormHelperText>
            )}
        </FormControl>
    );
};

export const FormSection = ({ title, children, description, ...props }) => {
    return (
        <Box sx={{ mb: 4 }} {...props}>
            {title && (
                <Typography variant="h6" gutterBottom>
                    {title}
                </Typography>
            )}
            {description && (
                <Typography variant="body2" color="text.secondary" sx={{ mb: 2 }}>
                    {description}
                </Typography>
            )}
            {children}
        </Box>
    );
};

export const FormRow = ({ children, spacing = 2, ...props }) => {
    return (
        <Box 
            sx={{ 
                display: 'flex', 
                gap: spacing, 
                alignItems: 'flex-start',
                flexWrap: 'wrap'
            }} 
            {...props}
        >
            {children}
        </Box>
    );
};

export const FormError = ({ errors, field }) => {
    if (!errors || !errors[field]) return null;
    
    return (
        <FormHelperText error>
            {errors[field]}
        </FormHelperText>
    );
};

export const FormSuccess = ({ message }) => {
    if (!message) return null;
    
    return (
        <Box sx={{ 
            p: 2, 
            mb: 2, 
            backgroundColor: 'success.light', 
            color: 'success.contrastText',
            borderRadius: 1
        }}>
            <Typography variant="body2">
                {message}
            </Typography>
        </Box>
    );
};

export const FormInfo = ({ message }) => {
    if (!message) return null;
    
    return (
        <Box sx={{ 
            p: 2, 
            mb: 2, 
            backgroundColor: 'info.light', 
            color: 'info.contrastText',
            borderRadius: 1
        }}>
            <Typography variant="body2">
                {message}
            </Typography>
        </Box>
    );
};
