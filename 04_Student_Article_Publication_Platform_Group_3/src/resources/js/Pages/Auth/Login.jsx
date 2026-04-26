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
  FormControlLabel,
  Checkbox,
  Fade,
  Slide,
  Zoom,
  Chip,
  Avatar,
  alpha
} from '@mui/material';
import {
  Visibility,
  VisibilityOff,
  Email,
  Lock,
  Dashboard,
  Rocket,
  Shield,
  EmojiEmotions as EmojiIcon,
  Brush as BrushIcon,
  Pets as PetsIcon,
  Cake as CakeIcon,
  MusicNote as MusicIcon,
  AutoStories,
  Star,
  Whatshot as FireIcon,
  WbSunny as SunIcon,
  Cloud as CloudIcon,
  Forest as ForestIcon,
  ThumbUp,
  Celebration
} from '@mui/icons-material';

export default function Login({ status, canResetPassword }) {
  const { data, setData, post, processing, errors, reset } = useForm({
    email: '',
    password: '',
    remember: false,
  });

  const [showPassword, setShowPassword] = useState(false);
  const [animateContent, setAnimateContent] = useState(false);
  const [floatingIcons, setFloatingIcons] = useState([]);
  const [selectedCharacter, setSelectedCharacter] = useState(null);

  useEffect(() => {
    setAnimateContent(true);
    generateFloatingIcons();
  }, []);

  const generateFloatingIcons = () => {
    const icons = [
      <BrushIcon />, <PetsIcon />, <CakeIcon />, <MusicIcon />,
      <Star />, <FireIcon />, <SunIcon />, <CloudIcon />, <ForestIcon />
    ];
    const positions = [];
    for (let i = 0; i < 15; i++) {
      positions.push({
        icon: icons[Math.floor(Math.random() * icons.length)],
        left: Math.random() * 100,
        top: Math.random() * 100,
        delay: Math.random() * 5,
        duration: 8 + Math.random() * 15,
        size: 15 + Math.random() * 25,
        rotation: Math.random() * 360
      });
    }
    setFloatingIcons(positions);
  };

  const submit = (e) => {
    e.preventDefault();
    post(route('login'), {
      onFinish: () => reset('password'),
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
    cardBg: '#FFFFFF',
  };

  // Character options for fun selection
  const characters = [
    { emoji: '🦊', name: 'Fox', color: colors.orange },
    { emoji: '🐼', name: 'Panda', color: colors.text },
    { emoji: '🐨', name: 'Koala', color: colors.purple },
    { emoji: '🦁', name: 'Lion', color: colors.primary },
    { emoji: '🐧', name: 'Penguin', color: colors.blue },
    { emoji: '🦉', name: 'Owl', color: colors.green }
  ];

  return (
    <>
      <Head title="Sign In - StoryLand" />

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
                transform: `rotate(${item.rotation}deg)`,
                animation: `float ${item.duration}s infinite ease-in-out`,
                animationDelay: `${item.delay}s`,
                '@keyframes float': {
                  '0%': { transform: `rotate(${item.rotation}deg) translateY(0px)` },
                  '50%': { transform: `rotate(${item.rotation + 10}deg) translateY(-20px)` },
                  '100%': { transform: `rotate(${item.rotation}deg) translateY(0px)` },
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
          top: '10%',
          left: '5%',
          animation: 'cloudMove 25s infinite linear',
          '@keyframes cloudMove': {
            '0%': { transform: 'translateX(-100px)' },
            '100%': { transform: 'translateX(100vw)' }
          },
          zIndex: 0
        }}>
          <CloudIcon sx={{ fontSize: 80, color: 'rgba(255,255,255,0.2)' }} />
        </Box>
        <Box sx={{
          position: 'absolute',
          bottom: '15%',
          right: '5%',
          animation: 'cloudMoveReverse 30s infinite linear',
          '@keyframes cloudMoveReverse': {
            '0%': { transform: 'translateX(100px)' },
            '100%': { transform: 'translateX(-100vw)' }
          },
          zIndex: 0
        }}>
          <CloudIcon sx={{ fontSize: 60, color: 'rgba(255,255,255,0.2)' }} />
        </Box>

        {/* Main Container */}
        <Box
          sx={{
            display: 'flex',
            width: '100%',
            maxWidth: 1200,
            minHeight: { xs: 'auto', md: 650 },
            boxShadow: '12px 12px 0 rgba(0,0,0,0.2)',
            borderRadius: 8,
            overflow: 'hidden',
            position: 'relative',
            zIndex: 2,
            border: `4px solid ${colors.accent}`,
          }}
        >
          {/* Left Panel - Sign In Form */}
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
                  width: 100,
                  height: 100,
                  background: `url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 100 100'%3E%3Ccircle cx='20' cy='20' r='8' fill='${colors.accent.replace('#', '%23')}' opacity='0.3'/%3E%3Ccircle cx='60' cy='40' r='12' fill='${colors.primary.replace('#', '%23')}' opacity='0.2'/%3E%3Ccircle cx='80' cy='80' r='16' fill='${colors.secondary.replace('#', '%23')}' opacity='0.2'/%3E%3C/svg%3E")`,
                  backgroundSize: 'cover',
                  opacity: 0.5
                }
              }}
            >
              <Paper 
                elevation={0} 
                sx={{ 
                  width: '100%', 
                  maxWidth: 400, 
                  bgcolor: 'transparent',
                  position: 'relative',
                  zIndex: 2
                }}
              >
                {/* Character Selection */}
                <Zoom in={animateContent} timeout={1000}>
                  <Box sx={{ mb: 4, textAlign: 'center' }}>
                    <Typography
                      variant="overline"
                      sx={{
                        fontFamily: '"Comic Sans MS", cursive',
                        fontSize: '1rem',
                        color: colors.purple,
                        bgcolor: colors.accent,
                        p: 1,
                        px: 3,
                        borderRadius: 30,
                        display: 'inline-block',
                        mb: 2
                      }}
                    >
                      🎭 Choose Your Character 🎭
                    </Typography>
                    <Box sx={{ display: 'flex', gap: 1, justifyContent: 'center', flexWrap: 'wrap' }}>
                      {characters.map((char, index) => (
                        <Avatar
                          key={index}
                          onClick={() => setSelectedCharacter(char)}
                          sx={{
                            bgcolor: selectedCharacter?.name === char.name ? colors.accent : 'white',
                            color: char.color,
                            border: `3px solid ${selectedCharacter?.name === char.name ? colors.primary : colors.secondary}`,
                            cursor: 'pointer',
                            width: 50,
                            height: 50,
                            fontSize: '1.8rem',
                            transition: 'all 0.3s ease',
                            '&:hover': {
                              transform: 'scale(1.2) rotate(5deg)',
                              borderColor: colors.accent
                            }
                          }}
                        >
                          {char.emoji}
                        </Avatar>
                      ))}
                    </Box>
                  </Box>
                </Zoom>

                <Fade in={animateContent} timeout={1200}>
                  <Box sx={{ textAlign: 'center', mb: 3 }}>
                    <Box
                      sx={{
                        bgcolor: colors.accent,
                        borderRadius: '50%',
                        width: 80,
                        height: 80,
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
                      <AutoStories sx={{ fontSize: 40, color: colors.primary }} />
                    </Box>
                    <Typography
                      variant="h4"
                      sx={{
                        fontFamily: '"Comic Sans MS", cursive',
                        fontWeight: 'bold',
                        color: colors.primary,
                        mb: 1,
                        textShadow: `3px 3px 0 ${alpha(colors.primary, 0.3)}`
                      }}
                    >
                      Welcome Back!
                    </Typography>
                    <Typography
                      variant="body1"
                      sx={{
                        fontFamily: '"Comic Sans MS", cursive',
                        color: colors.text,
                      }}
                    >
                      Your next adventure awaits! ✨
                    </Typography>
                  </Box>
                </Fade>

                {status && (
                  <Zoom in={true} timeout={500}>
                    <Chip
                      icon={<Celebration />}
                      label={status}
                      sx={{
                        mb: 3,
                        bgcolor: colors.green,
                        color: 'white',
                        fontFamily: '"Comic Sans MS", cursive',
                        fontSize: '1rem',
                        p: 2,
                        width: '100%',
                        height: 'auto',
                        '& .MuiChip-label': { whiteSpace: 'normal', textAlign: 'center' }
                      }}
                    />
                  </Zoom>
                )}

                <form onSubmit={submit}>
                  {/* Email Field */}
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
                        📧 Your Email
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

                  {/* Password Field */}
                  <Grow in={animateContent} timeout={1200}>
                    <Box sx={{ mb: 2 }}>
                      <Typography
                        variant="subtitle2"
                        sx={{
                          fontFamily: '"Comic Sans MS", cursive',
                          color: colors.purple,
                          mb: 1,
                          ml: 1
                        }}
                      >
                        🔒 Secret Password
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
                          placeholder="Enter your password"
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
                    </Box>
                  </Grow>

                  {/* Remember Me & Forgot Password */}
                  <Grow in={animateContent} timeout={1400}>
                    <Box sx={{ 
                      display: 'flex', 
                      justifyContent: 'space-between', 
                      alignItems: 'center',
                      flexWrap: 'wrap',
                      mb: 3
                    }}>
                      <FormControlLabel
                        control={
                          <Checkbox
                            checked={data.remember}
                            onChange={(e) => setData('remember', e.target.checked)}
                            sx={{
                              color: colors.secondary,
                              '&.Mui-checked': {
                                color: colors.primary,
                              },
                            }}
                          />
                        }
                        label={
                          <Typography sx={{ fontFamily: '"Comic Sans MS", cursive', color: colors.text }}>
                            Remember me
                          </Typography>
                        }
                      />

                      {canResetPassword && (
                        <Link
                          href={route('password.request')}
                          style={{ textDecoration: 'none' }}
                        >
                          <Typography
                            sx={{
                              fontFamily: '"Comic Sans MS", cursive',
                              color: colors.purple,
                              fontWeight: 'bold',
                              '&:hover': {
                                color: colors.primary,
                                transform: 'scale(1.05)'
                              },
                              transition: 'all 0.3s ease'
                            }}
                          >
                            Forgot password? 🧸
                          </Typography>
                        </Link>
                      )}
                    </Box>
                  </Grow>

                  {/* Sign In Button */}
                  <Grow in={animateContent} timeout={1600}>
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
                      {processing ? 'Opening the magic door...' : 'Let\'s Go!'} 🚀
                    </Button>
                  </Grow>
                </form>
              </Paper>
            </Box>
          </Slide>

          {/* Right Panel - Playful Sign Up Message */}
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
                      <BrushIcon sx={{ fontSize: 50, color: colors.accent, animationDelay: '0s' }} />
                      <PetsIcon sx={{ fontSize: 50, color: colors.accent, animationDelay: '0.3s' }} />
                      <MusicIcon sx={{ fontSize: 50, color: colors.accent, animationDelay: '0.6s' }} />
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
                      New Friend! 🎉
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
                      Join our magical world of articles, creativity, and endless adventures!
                    </Typography>

                    {/* Fun Features */}
                    <Box
                      sx={{
                        display: 'flex',
                        flexDirection: 'column',
                        gap: 2,
                        my: 4,
                        bgcolor: alpha('#FFFFFF', 0.1),
                        p: 3,
                        borderRadius: 8,
                        border: `2px dashed ${colors.accent}`
                      }}
                    >
                      <Box sx={{ display: 'flex', alignItems: 'center', gap: 2 }}>
                        <Box sx={{ bgcolor: colors.accent, borderRadius: '50%', p: 1, display: 'flex' }}>
                          <Star sx={{ color: colors.primary }} />
                        </Box>
                        <Typography variant="body1" sx={{ fontFamily: '"Comic Sans MS", cursive' }}>
                          Create your own articles
                        </Typography>
                      </Box>
                      <Box sx={{ display: 'flex', alignItems: 'center', gap: 2 }}>
                        <Box sx={{ bgcolor: colors.accent, borderRadius: '50%', p: 1, display: 'flex' }}>
                          <ThumbUp sx={{ color: colors.primary }} />
                        </Box>
                        <Typography variant="body1" sx={{ fontFamily: '"Comic Sans MS", cursive' }}>
                          Meet new friends
                        </Typography>
                      </Box>
                      <Box sx={{ display: 'flex', alignItems: 'center', gap: 2 }}>
                        <Box sx={{ bgcolor: colors.accent, borderRadius: '50%', p: 1, display: 'flex' }}>
                          <Celebration sx={{ color: colors.primary }} />
                        </Box>
                        <Typography variant="body1" sx={{ fontFamily: '"Comic Sans MS", cursive' }}>
                          Earn magical badges
                        </Typography>
                      </Box>
                    </Box>

                    <Grow in={animateContent} timeout={2200}>
                      <Link
                        href={route('register')}
                        style={{ textDecoration: 'none' }}
                      >
                        <Button
                          variant="contained"
                          size="large"
                          startIcon={<Rocket />}
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
                          Start Your Adventure!
                        </Button>
                      </Link>
                    </Grow>

                    <Typography
                      variant="caption"
                      sx={{
                        display: 'block',
                        mt: 3,
                        color: alpha('#FFFFFF', 0.8),
                        fontFamily: '"Comic Sans MS", cursive'
                      }}
                    >
                      Already 10,000+ happy storytellers! 🌟
                    </Typography>
                  </Box>
                </Zoom>
              </Box>
            </Box>
          </Slide>
        </Box>

        {/* Fun Footer Note */}
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
          ✨ Every article starts with a single word... ✨
        </Typography>
      </Box>
    </>
  );
}