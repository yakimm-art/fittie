# ElevenLabs Integration Guide

## Overview
ElevenLabs provides AI-powered text-to-speech for Fittie's voice coaching system. This guide covers setup, testing, and best practices.

## Quick Start

### 1. Get API Key
1. Create account at [elevenlabs.io](https://elevenlabs.io)
2. Navigate to Profile Settings → API Keys
3. Generate new API key
4. Store in `.env` file:
   ```bash
   ELEVENLABS_API_KEY=your_api_key_here
   ```

### 2. Test API
```bash
export ELEVENLABS_API_KEY=your_api_key_here
./scripts/test-elevenlabs.sh
```

The test script will:
- Generate sample coaching audio files
- Test streaming API for low latency
- Fetch available voices
- Check your usage limits

## API Endpoints

### Text-to-Speech (Standard)
```bash
POST https://api.elevenlabs.io/v1/text-to-speech/{voice_id}
```
- **Latency**: ~2-3 seconds
- **Use case**: Pre-generated coaching cues

### Text-to-Speech (Streaming)
```bash
POST https://api.elevenlabs.io/v1/text-to-speech/{voice_id}/stream
```
- **Latency**: ~300-500ms (first chunk)
- **Use case**: Real-time coaching feedback
- **Recommended**: Use for Fittie's dynamic coaching

### Get Voices
```bash
GET https://api.elevenlabs.io/v1/voices
```
- Returns all available voices
- Includes voice characteristics and labels

### User Info & Usage
```bash
GET https://api.elevenlabs.io/v1/user
```
- Check subscription tier
- Monitor character usage
- View rate limits

## Pricing & Rate Limits

### Free Tier
- **Characters**: 10,000/month
- **Voices**: Limited selection
- **Commercial use**: No
- **API calls**: Rate limited

### Creator Tier (~$5/month)
- **Characters**: 30,000/month
- **Voices**: All voices
- **Commercial use**: Yes
- **API calls**: Higher limits

### Pro Tier (~$22/month)
- **Characters**: 100,000/month
- **Voices**: All voices + voice cloning
- **Commercial use**: Yes
- **API calls**: Production ready

### Estimate for Fittie Demo
- **Coaching cues**: ~20 words each
- **Cues per workout**: ~50-100
- **Characters per workout**: ~1,000-2,000
- **Monthly demo usage**: ~10-20 workouts = 10,000-40,000 characters
- **Recommended tier**: Creator or Pro

## Voice Selection for Coaching

### Recommended Voices

#### Rachel (21m00Tcm4TlvDq8ikWAM)
- **Tone**: Calm, clear, professional
- **Use case**: General coaching, form corrections
- **Energy**: Medium

#### Bella (EXAVITQu4vr4xnSDxMaL)
- **Tone**: Energetic, motivating
- **Use case**: Encouragement, high-intensity moments
- **Energy**: High

#### Josh (TxGEqnHWrfWFTfGW9XjX)
- **Tone**: Confident, encouraging
- **Use case**: Alternative voice, strength coaching
- **Energy**: Medium-High

### Voice Settings

**For coaching context:**
```json
{
  "stability": 0.5,
  "similarity_boost": 0.75
}
```

- **Stability**: 0.3-0.5 (dynamic, natural variation)
- **Similarity Boost**: 0.7-0.8 (consistent voice quality)

## Integration with Fittie

### Architecture
```
Fittie Backend (Lambda)
    ↓
ElevenLabs API (Streaming)
    ↓
Audio Chunks → S3 → CloudFront
    ↓
Fittie Frontend (Audio Playback)
```

### Caching Strategy
1. **Pre-generate common cues** (e.g., "Good job!", "Keep going!")
2. **Store in S3** with CloudFront CDN
3. **Generate dynamic cues** on-demand for personalized feedback
4. **Cache generated audio** for 24 hours

### Latency Optimization
- Use **streaming endpoint** for real-time feedback
- **Pre-fetch** next likely coaching cue
- **Batch generate** workout-specific cues at workout start
- **WebSocket** connection for continuous audio delivery

## Security Best Practices

1. **Never commit API keys** to repository
2. **Use environment variables** or AWS Secrets Manager
3. **Rotate keys** periodically
4. **Monitor usage** to detect anomalies
5. **Set up billing alerts** in ElevenLabs dashboard

## Error Handling

### Common Errors

**401 Unauthorized**
- Check API key validity
- Ensure key is properly formatted in header

**429 Too Many Requests**
- Rate limit exceeded
- Implement exponential backoff
- Consider caching strategy

**422 Unprocessable Entity**
- Text too long (max: ~5,000 characters per request)
- Invalid voice settings
- Unsupported characters in text

### Retry Logic
```javascript
const maxRetries = 3;
const backoff = [1000, 2000, 4000]; // ms

for (let i = 0; i < maxRetries; i++) {
  try {
    return await elevenLabsAPI.synthesize(text);
  } catch (error) {
    if (i === maxRetries - 1) throw error;
    await sleep(backoff[i]);
  }
}
```

## Testing Checklist

- [ ] API key obtained and stored securely
- [ ] Test script runs successfully
- [ ] Audio quality meets requirements
- [ ] Streaming API latency acceptable (<1s)
- [ ] Voice selection finalized
- [ ] Rate limits documented
- [ ] Error handling implemented
- [ ] Caching strategy defined
- [ ] Monthly cost estimated

## Resources

- [ElevenLabs API Documentation](https://docs.elevenlabs.io/)
- [Voice Lab](https://elevenlabs.io/voice-lab) - Test voices
- [Pricing Page](https://elevenlabs.io/pricing)
- [API Status](https://status.elevenlabs.io/)

## Next Steps

1. Run `./scripts/test-elevenlabs.sh` to test API
2. Listen to generated audio samples
3. Select primary and alternate voices
4. Estimate monthly usage for Fittie
5. Choose appropriate subscription tier
6. Integrate with Lambda functions
7. Implement caching and error handling
