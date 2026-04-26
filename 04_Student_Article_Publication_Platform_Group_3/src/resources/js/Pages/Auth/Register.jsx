import { useState, useEffect } from 'react';
import { Head, Link, useForm } from '@inertiajs/react';
import {
  TextField,
  Button,
  IconButton,
  Typography,
  Box,
  Paper,
  Grow,
  Fade,
  Slide,
  FormControl,
  InputLabel,
  Select,
  MenuItem,
  Chip,
  Avatar,
  Zoom,
  alpha
} from '@mui/material';
import {
  Visibility,
  VisibilityOff,
  Person,
  Email,
  Lock,
  PersonAdd,
  CheckCircle,
  FlashOn,
  AccountCircle,
  Brush as BrushIcon,
  Pets as PetsIcon,
  Cake as CakeIcon,
  MusicNote as MusicIcon,
  AutoStories,
  Star,
  Celebration,
  Rocket,
  ThumbUp,
  Forest as ForestIcon,
  WbSunny as SunIcon,
  Cloud as CloudIcon
} from '@mui/icons-material';

export default function Register() {
  const { data, setData, post, processing, errors, reset } = useForm({
    name: '',
    email: '',
    password: '',
    password_confirmation: '',
    role: 'writer',
    favorite_character: '',
    favorite_color: 'coral'
  });

  const [showPassword, setShowPassword] = useState(false);
  const [showConfirmPassword, setShowConfirmPassword] = useState(false);
  const [animateContent, setAnimateContent] = useState(false);
  const [floatingIcons, setFloatingIcons] = useState([]);
  const [passwordStrength, setPasswordStrength] = useState(0);

  useEffect(() => {
    setAnimateContent(true);
    generateFloatingIcons();
  }, []);

  useEffect(() => {
    // Calculate password strength
    const password = data.password;
    let strength = 0;
    if (password.length > 0) strength += 20;
    if (password.length >= 8) strength += 20;
    if (/[A-Z]/.test(password)) strength += 20;
    if (/[0-9]/.test(password)) strength += 20;
    if (/[^A-Za-z0-9]/.test(password)) strength += 20;
    setPasswordStrength(strength);
  }, [data.password]);

  const generateFloatingIcons = () => {
    const icons = [
      <BrushIcon />, <PetsIcon />, <CakeIcon />, <MusicIcon />,
      <Star />, <ForestIcon />, <SunIcon />, <CloudIcon />
    ];
    const positions = [];
    for (let i = 0; i < 15; i++) {
      positions.push({
        icon: icons[Math.floor(Math.random() * icons.length)],
        left: Math.random() * 100,
        top: Math.random() * 100,
        delay: Math.random() * 5,
        duration: 8 + Math.random() * 15,
        size: 15 + Math.random() * 25
      });
    }
    setFloatingIcons(positions);
  };

  const submit = (e) => {
    e.preventDefault();
    post(route('register'), {
      onFinish: () => reset('password', 'password_confirmation'),
    });
  };

  // Cartoon color palette
  const colors = {
    primary: '#FF6B6B', // Coral red
    secondary: '#4ECDC4', // Turquoise
    accent: '#FFE66D', // Sunny yellow
    purple: '#9B6B9E', // Soft purple
    orange: '#FF9F1C', // Bright orange
    pink: '#FF8A80', // Soft pink
    green: '#6BAA6B', // Forest green
    blue: '#6B8CFF', // Sky blue
    background: '#FFF9E6', // Creamy white
    text: '#4A4A4A', // Soft black
  };

  // Color options for avatar
  const colorOptions = [
    { value: 'coral', color: colors.primary, name: 'Coral' },
    { value: 'turquoise', color: colors.secondary, name: 'Turquoise' },
    { value: 'purple', color: colors.purple, name: 'Purple' },
    { value: 'green', color: colors.green, name: 'Green' },
    { value: 'orange', color: colors.orange, name: 'Orange' },
    { value: 'blue', color: colors.blue, name: 'Blue' }
  ];

  // Character options
  const characters = [
    { emoji: '🦊', name: 'Felix the Fox', value: 'fox' },
    { emoji: '🐼', name: 'Penny the Panda', value: 'panda' },
    { emoji: '🦁', name: 'Leo the Lion', value: 'lion' },
    { emoji: '🦉', name: 'Ollie the Owl', value: 'owl' },
    { emoji: '🐨', name: 'Kody the Koala', value: 'koala' },
    { emoji: '🐧', name: 'Pippin the Penguin', value: 'penguin' }
  ];

  return (
    <>
      <Head title="Join Scribble Press - Start Your Adventure!" />

      <Box
        sx={{
          display: 'flex',
          minHeight: '100vh',
          background: `linear-gradient(135deg, ${colors.blue} 0%, ${colors.secondary} 50%, ${colors.green} 100%)`,
          position: 'relative',
          overflow: 'hidden',
          alignItems: 'center',
          justifyContent: 'center',
          p: 2,
        }}
      >
        {/* Floating Background Icons */}
        <Box sx={{
          position: 'absolute',
          top: 0,
          left: 0,
          right: 0,
          bottom: 0,
          pointerEvents: 'none',
          zIndex: 0,
        }}>
          {floatingIcons.map((item, index) => (
            <Box
              key={index}
              sx={{
                position: 'absolute',
                left: `${item.left}%`,
                top: `${item.top}%`,
                color: [colors.accent, colors.pink, colors.purple, colors.orange][Math.floor(Math.random() * 4)],
                opacity: 0.15,
                fontSize: item.size,
                animation: `float ${item.duration}s infinite ease-in-out`,
                animationDelay: `${item.delay}s`,
                '@keyframes float': {
                  '0%': { transform: 'translateY(0px) rotate(0deg)' },
                  '50%': { transform: 'translateY(-20px) rotate(10deg)' },
                  '100%': { transform: 'translateY(0px) rotate(0deg)' },
                }
              }}
            >
              {item.icon}
            </Box>
          ))}
        </Box>

        {/* Animated Clouds */}
        <Box sx={{
          position: 'absolute',
          top: '5%',
          left: '5%',
          animation: 'cloudMove 30s infinite linear',
          '@keyframes cloudMove': {
            '0%': { transform: 'translateX(-100px)' },
            '100%': { transform: 'translateX(100vw)' }
          },
          zIndex: 0
        }}>
          <CloudIcon sx={{ fontSize: 100, color: 'rgba(255,255,255,0.2)' }} />
        </Box>
        <Box sx={{
          position: 'absolute',
          bottom: '10%',
          right: '5%',
          animation: 'cloudMoveReverse 35s infinite linear',
          '@keyframes cloudMoveReverse': {
            '0%': { transform: 'translateX(100px)' },
            '100%': { transform: 'translateX(-100vw)' }
          },
          zIndex: 0
        }}>
          <CloudIcon sx={{ fontSize: 70, color: 'rgba(255,255,255,0.2)' }} />
        </Box>

        {/* Main Container */}
        <Box
          sx={{
            display: 'flex',
            width: '100%',
            maxWidth: 1200,
            minHeight: { xs: 'auto', md: 700 },
            boxShadow: '12px 12px 0 rgba(0,0,0,0.2)',
            borderRadius: 8,
            overflow: 'hidden',
            position: 'relative',
            zIndex: 2,
            border: `4px solid ${colors.accent}`,
          }}
        >
          {/* Left Panel - Registration Form */}
          <Slide direction="right" in={animateContent} timeout={800}>
            <Box
              sx={{
                flex: 1,
                display: 'flex',
                alignItems: 'center',
                justifyContent: 'center',
                bgcolor: colors.background,
                p: 4,
                position: 'relative',
                '&::before': {
                  content: '""',
                  position: 'absolute',
                  top: 10,
                  left: 10,
                  width: 150,
                  height: 150,
                  background: `radial-gradient(circle, ${alpha(colors.accent, 0.2)} 0%, transparent 70%)`,
                  borderRadius: '50%'
                },
                '&::after': {
                  content: '""',
                  position: 'absolute',
                  bottom: 10,
                  right: 10,
                  width: 100,
                  height: 100,
                  background: `radial-gradient(circle, ${alpha(colors.primary, 0.2)} 0%, transparent 70%)`,
                  borderRadius: '50%'
                }
              }}
            >
              <Paper 
                elevation={0} 
                sx={{ 
                  width: '100%', 
                  maxWidth: 450, 
                  bgcolor: 'transparent',
                  position: 'relative',
                  zIndex: 2
                }}
              >
                {/* Welcome Header */}
                <Zoom in={animateContent} timeout={1000}>
                  <Box sx={{ textAlign: 'center', mb: 4 }}>
                    <Box
                      sx={{
                        bgcolor: colors.accent,
                        borderRadius: '50%',
                        width: 90,
                        height: 90,
                        display: 'flex',
                        alignItems: 'center',
                        justifyContent: 'center',
                        mx: 'auto',
                        mb: 2,
                        animation: 'bounce 2s infinite',
                        '@keyframes bounce': {
                          '0%, 100%': { transform: 'translateY(0)' },
                          '50%': { transform: 'translateY(-10px)' }
                        }
                      }}
                    >
                      <AutoStories sx={{ fontSize: 50, color: colors.primary }} />
                    </Box>
                    <Typography
                      variant="h3"
                      sx={{
                        fontFamily: '"Comic Sans MS", cursive',
                        fontWeight: 'bold',
                        color: colors.primary,
                        mb: 1,
                        textShadow: `3px 3px 0 ${alpha(colors.primary, 0.3)}`
                      }}
                    >
                      Join the Fun! 🎉
                    </Typography>
                    <Typography
                      variant="h6"
                      sx={{
                        fontFamily: '"Comic Sans MS", cursive',
                        color: colors.text,
                      }}
                    >
                      Create your magical profile
                    </Typography>
                  </Box>
                </Zoom>

                <form onSubmit={submit}>
                  {/* Name Field */}
                  <Grow in={animateContent} timeout={1000}>
                    <Box sx={{ mb: 3 }}>
                      <Typography
                        variant="subtitle2"
                        sx={{
                          fontFamily: '"Comic Sans MS", cursive',
                          color: colors.purple,
                          mb: 1,
                          ml: 1
                        }}
                      >
                        ✨ What should we call you?
                      </Typography>
                      <Box
                        sx={{
                          display: 'flex',
                          alignItems: 'center',
                          bgcolor: 'white',
                          border: `3px solid ${colors.secondary}`,
                          borderRadius: 40,
                          p: 1,
                          transition: 'all 0.3s ease',
                          '&:hover': {
                            borderColor: colors.primary,
                            transform: 'scale(1.02)'
                          },
                          '&:focus-within': {
                            borderColor: colors.accent,
                            boxShadow: `0 0 0 4px ${alpha(colors.accent, 0.3)}`
                          }
                        }}
                      >
                        <Person sx={{ color: colors.secondary, mx: 1, fontSize: 28 }} />
                        <TextField
                          placeholder="Enter your name"
                          variant="standard"
                          fullWidth
                          value={data.name}
                          onChange={(e) => setData('name', e.target.value)}
                          error={!!errors.name}
                          helperText={errors.name}
                          required
                          InputProps={{
                            disableUnderline: true,
                            sx: {
                              fontFamily: '"Comic Sans MS", cursive',
                              fontSize: '1rem'
                            }
                          }}
                        />
                      </Box>
                    </Box>
                  </Grow>

                  {/* Email Field */}
                  <Grow in={animateContent} timeout={1100}>
                    <Box sx={{ mb: 3 }}>
                      <Typography
                        variant="subtitle2"
                        sx={{
                          fontFamily: '"Comic Sans MS", cursive',
                          color: colors.purple,
                          mb: 1,
                          ml: 1
                        }}
                      >
                        📧 Your magical mail
                      </Typography>
                      <Box
                        sx={{
                          display: 'flex',
                          alignItems: 'center',
                          bgcolor: 'white',
                          border: `3px solid ${colors.secondary}`,
                          borderRadius: 40,
                          p: 1,
                          transition: 'all 0.3s ease',
                          '&:hover': {
                            borderColor: colors.primary,
                            transform: 'scale(1.02)'
                          },
                          '&:focus-within': {
                            borderColor: colors.accent,
                            boxShadow: `0 0 0 4px ${alpha(colors.accent, 0.3)}`
                          }
                        }}
                      >
                        <Email sx={{ color: colors.secondary, mx: 1, fontSize: 28 }} />
                        <TextField
                          placeholder="Enter your email"
                          type="email"
                          variant="standard"
                          fullWidth
                          value={data.email}
                          onChange={(e) => setData('email', e.target.value)}
                          error={!!errors.email}
                          helperText={errors.email}
                          required
                          InputProps={{
                            disableUnderline: true,
                            sx: {
                              fontFamily: '"Comic Sans MS", cursive',
                              fontSize: '1rem'
                            }
                          }}
                        />
                      </Box>
                    </Box>
                  </Grow>

                  {/* Password Field with Strength Meter */}
                  <Grow in={animateContent} timeout={1200}>
                    <Box sx={{ mb: 3 }}>
                      <Typography
                        variant="subtitle2"
                        sx={{
                          fontFamily: '"Comic Sans MS", cursive',
                          color: colors.purple,
                          mb: 1,
                          ml: 1
                        }}
                      >
                        🔒 Secret password
                      </Typography>
                      <Box
                        sx={{
                          display: 'flex',
                          alignItems: 'center',
                          bgcolor: 'white',
                          border: `3px solid ${colors.secondary}`,
                          borderRadius: 40,
                          p: 1,
                          transition: 'all 0.3s ease',
                          '&:hover': {
                            borderColor: colors.primary,
                            transform: 'scale(1.02)'
                          },
                          '&:focus-within': {
                            borderColor: colors.accent,
                            boxShadow: `0 0 0 4px ${alpha(colors.accent, 0.3)}`
                          }
                        }}
                      >
                        <Lock sx={{ color: colors.secondary, mx: 1, fontSize: 28 }} />
                        <TextField
                          placeholder="Create a password"
                          type={showPassword ? 'text' : 'password'}
                          variant="standard"
                          fullWidth
                          value={data.password}
                          onChange={(e) => setData('password', e.target.value)}
                          error={!!errors.password}
                          helperText={errors.password}
                          required
                          InputProps={{
                            disableUnderline: true,
                            sx: {
                              fontFamily: '"Comic Sans MS", cursive',
                              fontSize: '1rem'
                            },
                            endAdornment: (
                              <IconButton
                                onClick={() => setShowPassword(!showPassword)}
                                sx={{
                                  color: colors.primary,
                                  '&:hover': { transform: 'scale(1.2)' }
                                }}
                              >
                                {showPassword ? <VisibilityOff /> : <Visibility />}
                              </IconButton>
                            ),
                          }}
                        />
                      </Box>
                      
                      {/* Password Strength Meter */}
                      {data.password && (
                        <Box sx={{ mt: 1, px: 1 }}>
                          <Box sx={{ display: 'flex', gap: 0.5, mb: 0.5 }}>
                            {[1, 2, 3, 4, 5].map((level) => (
                              <Box
                                key={level}
                                sx={{
                                  height: 8,
                                  flex: 1,
                                  borderRadius: 4,
                                  bgcolor: passwordStrength >= level * 20 
                                    ? level <= 2 ? colors.primary
                                      : level <= 4 ? colors.orange
                                      : colors.green
                                    : colors.mediumGray,
                                  transition: 'all 0.3s ease'
                                }}
                              />
                            ))}
                          </Box>
                          <Typography variant="caption" sx={{ color: colors.text, fontFamily: '"Comic Sans MS", cursive' }}>
                            {passwordStrength <= 20 ? 'Too weak' :
                             passwordStrength <= 40 ? 'Could be stronger' :
                             passwordStrength <= 60 ? 'Getting better!' :
                             passwordStrength <= 80 ? 'Almost there!' :
                             'Super strong! 🌟'}
                          </Typography>
                        </Box>
                      )}
                    </Box>
                  </Grow>

                  {/* Confirm Password */}
                  <Grow in={animateContent} timeout={1400}>
                    <Box sx={{ mb: 3 }}>
                      <Typography
                        variant="subtitle2"
                        sx={{
                          fontFamily: '"Comic Sans MS", cursive',
                          color: colors.purple,
                          mb: 1,
                          ml: 1
                        }}
                      >
                        🔒 Confirm your secret
                      </Typography>
                      <Box
                        sx={{
                          display: 'flex',
                          alignItems: 'center',
                          bgcolor: 'white',
                          border: `3px solid ${colors.secondary}`,
                          borderRadius: 40,
                          p: 1,
                          transition: 'all 0.3s ease',
                          '&:hover': {
                            borderColor: colors.primary,
                            transform: 'scale(1.02)'
                          },
                          '&:focus-within': {
                            borderColor: colors.accent,
                            boxShadow: `0 0 0 4px ${alpha(colors.accent, 0.3)}`
                          }
                        }}
                      >
                        <Lock sx={{ color: colors.secondary, mx: 1, fontSize: 28 }} />
                        <TextField
                          placeholder="Confirm password"
                          type={showConfirmPassword ? 'text' : 'password'}
                          variant="standard"
                          fullWidth
                          value={data.password_confirmation}
                          onChange={(e) => setData('password_confirmation', e.target.value)}
                          error={!!errors.password_confirmation}
                          helperText={errors.password_confirmation}
                          required
                          InputProps={{
                            disableUnderline: true,
                            sx: {
                              fontFamily: '"Comic Sans MS", cursive',
                              fontSize: '1rem'
                            },
                            endAdornment: (
                              <IconButton
                                onClick={() => setShowConfirmPassword(!showConfirmPassword)}
                                sx={{
                                  color: colors.primary,
                                  '&:hover': { transform: 'scale(1.2)' }
                                }}
                              >
                                {showConfirmPassword ? <VisibilityOff /> : <Visibility />}
                              </IconButton>
                            ),
                          }}
                        />
                      </Box>
                    </Box>
                  </Grow>

                  {/* Character Selection */}
                  <Grow in={animateContent} timeout={1500}>
                    <Box sx={{ mb: 3 }}>
                      <Typography
                        variant="subtitle2"
                        sx={{
                          fontFamily: '"Comic Sans MS", cursive',
                          color: colors.purple,
                          mb: 1,
                          ml: 1
                        }}
                      >
                        🎭 Choose your article companion
                      </Typography>
                      <Box sx={{ display: 'flex', gap: 1, flexWrap: 'wrap', justifyContent: 'center' }}>
                        {characters.map((char) => (
                          <Chip
                            key={char.value}
                            icon={<Typography>{char.emoji}</Typography>}
                            label={char.name}
                            onClick={() => setData('favorite_character', char.value)}
                            sx={{
                              bgcolor: data.favorite_character === char.value ? colors.accent : 'white',
                              color: colors.text,
                              border: `2px solid ${data.favorite_character === char.value ? colors.primary : colors.secondary}`,
                              fontFamily: '"Comic Sans MS", cursive',
                              '&:hover': {
                                transform: 'scale(1.05)',
                                bgcolor: data.favorite_character === char.value ? colors.accent : alpha(colors.accent, 0.3)
                              },
                              transition: 'all 0.3s ease'
                            }}
                          />
                        ))}
                      </Box>
                    </Box>
                  </Grow>

                  {/* Role Selection */}
                  <Grow in={animateContent} timeout={1600}>
                    <Box sx={{ mb: 3 }}>
                      <Typography
                        variant="subtitle2"
                        sx={{
                          fontFamily: '"Comic Sans MS", cursive',
                          color: colors.purple,
                          mb: 1,
                          ml: 1
                        }}
                      >
                        📚 What brings you to Scribble Press?
                      </Typography>
                      <Box sx={{ display: 'flex', gap: 2, flexWrap: 'wrap' }}>
                        {[
                          { value: 'writer', label: '✍️ Article Writer', color: colors.primary },
                          { value: 'editor', label: '📝 Article Editor', color: colors.green },
                          { value: 'student', label: '📖 Article Reader', color: colors.blue }
                        ].map((option) => (
                          <Button
                            key={option.value}
                            variant={data.role === option.value ? 'contained' : 'outlined'}
                            onClick={() => setData('role', option.value)}
                            sx={{
                              flex: 1,
                              minWidth: 120,
                              bgcolor: data.role === option.value ? option.color : 'white',
                              color: data.role === option.value ? 'white' : option.color,
                              borderColor: option.color,
                              borderWidth: 2,
                              fontFamily: '"Comic Sans MS", cursive',
                              '&:hover': {
                                bgcolor: data.role === option.value ? option.color : alpha(option.color, 0.1),
                                transform: 'scale(1.05)'
                              },
                              transition: 'all 0.3s ease'
                            }}
                          >
                            {option.label}
                          </Button>
                        ))}
                      </Box>
                    </Box>
                  </Grow>

                  {/* Color Selection */}
                  <Grow in={animateContent} timeout={1700}>
                    <Box sx={{ mb: 4 }}>
                      <Typography
                        variant="subtitle2"
                        sx={{
                          fontFamily: '"Comic Sans MS", cursive',
                          color: colors.purple,
                          mb: 1,
                          ml: 1
                        }}
                      >
                        🎨 Pick your favorite color
                      </Typography>
                      <Box sx={{ display: 'flex', gap: 1, justifyContent: 'center' }}>
                        {colorOptions.map((option) => (
                          <Avatar
                            key={option.value}
                            onClick={() => setData('favorite_color', option.value)}
                            sx={{
                              bgcolor: option.color,
                              width: 40,
                              height: 40,
                              cursor: 'pointer',
                              border: data.favorite_color === option.value ? `3px solid ${colors.accent}` : '3px solid transparent',
                              transform: data.favorite_color === option.value ? 'scale(1.2)' : 'scale(1)',
                              '&:hover': {
                                transform: 'scale(1.2)',
                                opacity: 0.9
                              },
                              transition: 'all 0.3s ease'
                            }}
                          />
                        ))}
                      </Box>
                    </Box>
                  </Grow>

                  {/* Submit Button */}
                  <Grow in={animateContent} timeout={1800}>
                    <Button
                      type="submit"
                      fullWidth
                      variant="contained"
                      disabled={processing}
                      endIcon={<Rocket />}
                      sx={{
                        bgcolor: colors.primary,
                        color: 'white',
                        fontFamily: '"Comic Sans MS", cursive',
                        fontSize: '1.3rem',
                        py: 2,
                        borderRadius: 40,
                        border: `3px solid ${colors.accent}`,
                        '&:hover': {
                          bgcolor: colors.pink,
                          transform: 'scale(1.05) translateY(-3px)',
                          boxShadow: `0 8px 0 ${alpha(colors.primary, 0.5)}`
                        },
                        transition: 'all 0.3s ease'
                      }}
                    >
                      {processing ? 'Creating Magic...' : 'Start My Adventure!'} ✨
                    </Button>
                  </Grow>
                </form>

                {/* Terms */}
                <Typography
                  variant="caption"
                  sx={{
                    display: 'block',
                    textAlign: 'center',
                    mt: 2,
                    color: colors.text,
                    fontFamily: '"Comic Sans MS", cursive'
                  }}
                >
                  By joining, you agree to be awesome and have fun! 🌟
                </Typography>
              </Paper>
            </Box>
          </Slide>

          {/* Right Panel - Welcome Message */}
          <Slide direction="left" in={animateContent} timeout={800}>
            <Box
              sx={{
                flex: 1,
                background: `linear-gradient(135deg, ${colors.primary} 0%, ${colors.purple} 100%)`,
                color: 'white',
                display: 'flex',
                alignItems: 'center',
                justifyContent: 'center',
                flexDirection: 'column',
                p: 4,
                position: 'relative',
                overflow: 'hidden',
                borderLeft: `4px solid ${colors.accent}`,
              }}
            >
              {/* Decorative elements */}
              <Box
                sx={{
                  position: 'absolute',
                  top: -40,
                  right: -40,
                  width: 250,
                  height: 250,
                  borderRadius: '50%',
                  background: `radial-gradient(circle, ${alpha(colors.accent, 0.3)} 0%, transparent 70%)`,
                  animation: 'pulse 4s infinite',
                  '@keyframes pulse': {
                    '0%, 100%': { transform: 'scale(1)' },
                    '50%': { transform: 'scale(1.1)' }
                  }
                }}
              />
              <Box
                sx={{
                  position: 'absolute',
                  bottom: -60,
                  left: -60,
                  width: 200,
                  height: 200,
                  borderRadius: '50%',
                  background: `radial-gradient(circle, ${alpha(colors.accent, 0.2)} 0%, transparent 70%)`,
                  animation: 'pulse 5s infinite',
                  animationDelay: '1s'
                }}
              />

              {/* Content */}
              <Box sx={{ position: 'relative', zIndex: 1, textAlign: 'center' }}>
                <Zoom in={animateContent} timeout={2000}>
                  <Box>
                    <Box
                      sx={{
                        display: 'flex',
                        justifyContent: 'center',
                        gap: 2,
                        mb: 3,
                        '& > *': {
                          animation: 'wave 2s infinite',
                          '@keyframes wave': {
                            '0%, 100%': { transform: 'rotate(0deg)' },
                            '25%': { transform: 'rotate(20deg)' },
                            '75%': { transform: 'rotate(-20deg)' }
                          }
                        }
                      }}
                    >
                      <Celebration sx={{ fontSize: 60, color: colors.accent, animationDelay: '0s' }} />
                      <Star sx={{ fontSize: 60, color: colors.accent, animationDelay: '0.3s' }} />
                      <ThumbUp sx={{ fontSize: 60, color: colors.accent, animationDelay: '0.6s' }} />
                    </Box>

                    <Typography
                      variant="h2"
                      sx={{
                        fontFamily: '"Comic Sans MS", cursive',
                        fontWeight: 'bold',
                        mb: 2,
                        textShadow: '4px 4px 0 rgba(0,0,0,0.2)',
                        fontSize: { xs: '2.5rem', md: '3rem' }
                      }}
                    >
                      Adventure Awaits! 🌟
                    </Typography>

                    <Typography
                      variant="h5"
                      sx={{
                        fontFamily: '"Comic Sans MS", cursive',
                        mb: 4,
                        opacity: 0.95,
                        lineHeight: 1.6
                      }}
                    >
                      Already have a magic portal? Continue your journey!
                    </Typography>

                    {/* Fun Stats */}
                    <Box
                      sx={{
                        display: 'flex',
                        justifyContent: 'space-around',
                        my: 4,
                        bgcolor: alpha('#FFFFFF', 0.1),
                        p: 3,
                        borderRadius: 8
                      }}
                    >
                      <Box sx={{ textAlign: 'center' }}>
                        <Typography variant="h4" sx={{ fontFamily: '"Comic Sans MS", cursive', fontWeight: 'bold' }}>
                          10k+
                        </Typography>
                        <Typography variant="caption">Happy Storytellers</Typography>
                      </Box>
                      <Box sx={{ textAlign: 'center' }}>
                        <Typography variant="h4" sx={{ fontFamily: '"Comic Sans MS", cursive', fontWeight: 'bold' }}>
                          5k+
                        </Typography>
                        <Typography variant="caption">Stories Written</Typography>
                      </Box>
                      <Box sx={{ textAlign: 'center' }}>
                        <Typography variant="h4" sx={{ fontFamily: '"Comic Sans MS", cursive', fontWeight: 'bold' }}>
                          🌟
                        </Typography>
                        <Typography variant="caption">Magic Badges</Typography>
                      </Box>
                    </Box>

                    <Grow in={animateContent} timeout={2200}>
                      <Link
                        href={route('login')}
                        style={{ textDecoration: 'none' }}
                      >
                        <Button
                          variant="contained"
                          size="large"
                          sx={{
                            bgcolor: colors.accent,
                            color: colors.primary,
                            fontFamily: '"Comic Sans MS", cursive',
                            fontSize: '1.3rem',
                            fontWeight: 'bold',
                            py: 2,
                            px: 6,
                            borderRadius: 40,
                            border: '3px solid white',
                            '&:hover': {
                              bgcolor: '#FFD93D',
                              transform: 'scale(1.1) rotate(2deg)',
                              boxShadow: '0 10px 25px rgba(0,0,0,0.3)'
                            },
                            transition: 'all 0.3s ease'
                          }}
                        >
                          Sign In to Continue
                        </Button>
                      </Link>
                    </Grow>
                  </Box>
                </Zoom>
              </Box>
            </Box>
          </Slide>
        </Box>

        {/* Fun Footer */}
        <Typography
          variant="caption"
          sx={{
            position: 'absolute',
            bottom: 10,
            color: 'white',
            fontFamily: '"Comic Sans MS", cursive',
            textShadow: '2px 2px 0 rgba(0,0,0,0.2)',
            zIndex: 2,
            bgcolor: alpha(colors.purple, 0.5),
            p: 1,
            px: 3,
            borderRadius: 40,
            backdropFilter: 'blur(5px)'
          }}
        >
          🌈 Every great article starts with a single step... or a click! 🚀
        </Typography>
      </Box>
    </>
  );
}