import React, { useRef, useEffect } from 'react';
import JoditEditor from 'jodit-react';

const JoditEditorComponent = ({ value, onChange, placeholder = 'Start typing...' }) => {
    const editor = useRef(null);

    const config = {
        readonly: false,
        placeholder: placeholder,
        height: 400,
        toolbarAdaptive: false,
        toolbarSticky: true,
        showCharsCounter: true,
        showWordsCounter: true,
        showXPathInStatusbar: false,
        askBeforePasteHTML: false,
        askBeforePasteFromWord: false,
        defaultActionOnPaste: 'insert_clear_html',
        uploader: {
            insertImageAsBase64: true,
            imagesExtensions: ['jpg', 'png', 'jpeg', 'gif'],
            filesExtensions: ['pdf', 'doc', 'docx'],
            url: '/api/upload',
            format: 'json',
            method: 'POST',
            headers: {
                'X-CSRF-TOKEN': document.querySelector('meta[name="csrf-token"]')?.getAttribute('content')
            },
            processFileName: function (name) {
                return name.toLowerCase().replace(/[^a-z0-9]/g, '_');
            },
            pathVariableName: 'path',
            filesVariableName: 'files',
            withCredentials: false,
            prepareData: function (data) {
                return data;
            },
            isSuccess: function (resp) {
                return resp.success;
            },
            getMsg: function (resp) {
                return resp.msg;
            },
            process: function (resp) {
                return {
                    files: resp.data[this.filesVariableName] || [],
                    path: resp.data.path || '',
                    baseurl: resp.data.baseurl || '',
                    message: resp.msg || ''
                };
            },
            error: function (e) {
                this.j.e.message = e.message;
            },
            defaultHandlerSuccess: function (data) {
                let i = data.files.length;
                while (i--) {
                    const file = data.files[i];
                    this.j.insertImage(file.original, file.name, file.width, file.height);
                }
            },
            defaultHandlerError: function (e) {
                this.j.message.error(e.message);
            }
        },
        buttons: [
            'source', '|',
            'bold', 'strikethrough', 'underline', 'italic', '|',
            'superscript', 'subscript', '|',
            'ul', 'ol', '|',
            'outdent', 'indent', '|',
            'font', 'fontsize', 'brush', 'paragraph', '|',
            'image', 'table', 'link', '|',
            'align', 'undo', 'redo', '|',
            'hr', 'eraser', 'copyformat', '|',
            'symbol', 'fullsize', 'print'
        ],
        buttonsXS: [
            'bold', 'strikethrough', 'underline', 'italic', '|',
            'ul', 'ol', '|',
            'image', 'table', 'link', '|',
            'align', 'undo', 'redo', '|',
            'eraser', 'fullsize'
        ],
        extraButtons: [
            {
                name: 'insertCodeBlock',
                iconURL: 'data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHdpZHRoPSIyNCIgaGVpZ2h0PSIyNCIgdmlld0JveD0iMCAwIDI0IDI0Ij48cGF0aCBkPSJNOS40IDE2LjZMNC44IDEybDQuNi00LjZMOC42IDVsNiA2LTYgNnoiLz48L3N2Zz4=',
                tooltip: 'Insert Code Block',
                exec: function (editor) {
                    const selection = editor.selection.html;
                    editor.selection.insertHTML(`<pre><code>${selection || 'Your code here'}</code></pre>`);
                }
            }
        ]
    };

    return (
        <JoditEditor
            ref={editor}
            value={value}
            config={config}
            tabIndex={1}
            onBlur={newContent => onChange(newContent)}
        />
    );
};

export default JoditEditorComponent;
