export default function ApplicationLogo(props) {
    return (
        <svg
            {...props}
            viewBox="0 0 64 64"
            xmlns="http://www.w3.org/2000/svg"
            role="img"
            aria-label="Campus Press logo"
        >
            <rect x="4" y="4" width="56" height="56" rx="12" fill="currentColor" opacity="0.14" />
            <rect x="9" y="9" width="46" height="46" rx="10" fill="none" stroke="currentColor" strokeWidth="2.5" />
            <path
                d="M24 24h12M24 32h10M24 40h12"
                stroke="currentColor"
                strokeWidth="2.6"
                strokeLinecap="round"
            />
            <path
                d="M42 23v18M42 23c4 0 7 2 7 5.5S46 34 42 34"
                stroke="currentColor"
                strokeWidth="2.6"
                strokeLinecap="round"
                strokeLinejoin="round"
                fill="none"
            />
        </svg>
    );
}
