import { useState, useEffect, useRef } from 'react';
import JoditEditor from 'jodit-react';
import {
    Box,
    TextField,
    Typography,
    FormHelperText,
    Paper,
    Toolbar,
    Button,
    IconButton,
    Tooltip
} from '@mui/material';
import {
    FormatBold,
    FormatItalic,
    FormatUnderlined,
    FormatListBulleted,
    FormatListNumbered,
    FormatQuote,
    Code,
    Link,
    Image,
    VideoLibrary
} from '@mui/icons-material';

const JoditEditorComponent = ({
    value = '',
    onChange,
    placeholder = 'Start writing your article...',
    height = 400,
    error,
    helperText,
    disabled = false,
    showToolbar = true
}) => {
    const editorRef = useRef(null);
    const [content, setContent] = useState(value);

    useEffect(() => {
        setContent(value);
    }, [value]);

    const handleContentChange = (newContent) => {
        setContent(newContent);
        if (onChange) {
            onChange(newContent);
        }
    };

    const config = {
        readonly: disabled,
        placeholder: placeholder,
        height: height,
        theme: 'default',
        language: 'en',
        toolbarButtonSize: 'middle',
        toolbarAdaptive: false,
        showCharsCounter: true,
        showWordsCounter: true,
        showXPathInStatusbar: false,
        askBeforePasteHTML: true,
        askBeforePasteFromWord: true,
        defaultActionOnPaste: 'paste_as_text',
        buttons: [
            'source',
            '|',
            'bold',
            'italic',
            'underline',
            'strikethrough',
            '|',
            'ul',
            'ol',
            '|',
            'outdent',
            'indent',
            '|',
            'font',
            'fontsize',
            'brush',
            'paragraph',
            '|',
            'image',
            'video',
            'table',
            'link',
            '|',
            'align',
            'undo',
            'redo',
            '|',
            'hr',
            'copyformat',
            'fullsize',
            'print'
        ],
        buttonsXS: [
            'bold',
            'italic',
            'underline',
            '|',
            'ul',
            'ol',
            '|',
            'image',
            'link',
            '|',
            'fullsize'
        ],
        events: {
            afterInsertNode: function (node) {
                // Custom event handling for inserted nodes
                console.log('Node inserted:', node);
            }
        },
        uploader: {
            insertImageAsBase64URI: true,
            imagesExtensions: ['jpg', 'png', 'jpeg', 'gif'],
            processFileName: function (filename) {
                return filename.toLowerCase().replace(/[^a-z0-9]/g, '_');
            }
        },
        filebrowser: {
            ajax: {
                url: '/api/upload'
            }
        },
        style: {
            background: '#ffffff',
            color: '#333333'
        }
    };

    const customToolbarButtons = [
        {
            name: 'bold',
            tooltip: 'Bold',
            icon: <FormatBold />,
            command: 'bold'
        },
        {
            name: 'italic',
            tooltip: 'Italic',
            icon: <FormatItalic />,
            command: 'italic'
        },
        {
            name: 'underline',
            tooltip: 'Underline',
            icon: <FormatUnderlined />,
            command: 'underline'
        },
        {
            name: 'ul',
            tooltip: 'Bullet List',
            icon: <FormatListBulleted />,
            command: 'insertUnorderedList'
        },
        {
            name: 'ol',
            tooltip: 'Numbered List',
            icon: <FormatListNumbered />,
            command: 'insertOrderedList'
        },
        {
            name: 'quote',
            tooltip: 'Quote',
            icon: <FormatQuote />,
            command: 'formatBlock',
            value: 'blockquote'
        },
        {
            name: 'code',
            tooltip: 'Code',
            icon: <Code />,
            command: 'formatBlock',
            value: 'pre'
        },
        {
            name: 'link',
            tooltip: 'Insert Link',
            icon: <Link />,
            command: 'link'
        },
        {
            name: 'image',
            tooltip: 'Insert Image',
            icon: <Image />,
            command: 'image'
        },
        {
            name: 'video',
            tooltip: 'Insert Video',
            icon: <VideoLibrary />,
            command: 'video'
        }
    ];

    const executeCommand = (command, value = null) => {
        if (editorRef.current) {
            const editor = editorRef.current;
            if (typeof command === 'function') {
                command(editor);
            } else {
                editor.execCommand(command, false, value);
            }
        }
    };

    return (
        <Box sx={{ width: '100%' }}>
            {showToolbar && (
                <Paper 
                    elevation={1} 
                    sx={{ 
                        p: 1, 
                        mb: 1, 
                        display: 'flex', 
                        alignItems: 'center',
                        gap: 0.5,
                        backgroundColor: 'grey.50'
                    }}
                >
                    {customToolbarButtons.map((button) => (
                        <Tooltip key={button.name} title={button.tooltip}>
                            <IconButton
                                size="small"
                                onClick={() => executeCommand(button.command, button.value)}
                                sx={{
                                    '&:hover': {
                                        backgroundColor: 'action.hover'
                                    }
                                }}
                            >
                                {button.icon}
                            </IconButton>
                        </Tooltip>
                    ))}
                </Paper>
            )}
            
            <Paper 
                elevation={2} 
                sx={{ 
                    overflow: 'hidden',
                    border: error ? 2 : 1,
                    borderColor: error ? 'error.main' : 'divider.main'
                }}
            >
                <JoditEditor
                    ref={editorRef}
                    value={content}
                    config={config}
                    tabIndex={1}
                    onBlur={(newContent) => handleContentChange(newContent)}
                    onChange={handleContentChange}
                />
            </Paper>
            
            {helperText && (
                <FormHelperText error={error} sx={{ mt: 1 }}>
                    {helperText}
                </FormHelperText>
            )}
        </Box>
    );
};

export default JoditEditorComponent;
