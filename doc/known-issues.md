# Known Issues

This document tracks current bugs, limitations, and areas for improvement in the Home Grocery App.

## 🐛 Current Bugs

### High Priority

#### 1. Build Errors Due to Import Path Issues
**Status**: 🔴 Active  
**Severity**: High  
**Description**: After project restructuring attempts, many import paths are broken causing build failures  
**Impact**: App cannot be built or run  
**Workaround**: Use original folder structure (Data/, Screens/, Reusable/)  
**Fix Required**: 
- Either fix all import paths in new structure
- Or revert to original structure completely

#### 2. Provider Initialization Issues
**Status**: 🔴 Active  
**Severity**: Medium  
**Description**: Some providers may not initialize correctly on first app launch  
**Impact**: App may crash or show empty data initially  
**Workaround**: Restart app if data doesn't load  
**Expected Fix**: v0.3.1

### Medium Priority

#### 3. Firebase Sync Intermittent Failures
**Status**: 🟡 Investigating  
**Severity**: Medium  
**Description**: Occasional failures when syncing data to Firebase  
**Impact**: Data may not sync across devices  
**Workaround**: Manually trigger sync in settings  
**Root Cause**: Network timeout handling needs improvement

#### 4. Memory Leaks in Navigation
**Status**: 🟡 Investigating  
**Severity**: Medium  
**Description**: Memory usage increases with repeated navigation  
**Impact**: App performance degradation over time  
**Workaround**: Restart app if becomes sluggish  
**Investigation**: Provider disposal and widget lifecycle

### Low Priority

#### 5. UI Flicker During Theme Changes
**Status**: 🟢 Known  
**Severity**: Low  
**Description**: Brief flicker when switching between dark/light themes  
**Impact**: Minor visual glitch  
**Workaround**: None needed  
**Future Fix**: Planned for v0.4.0

#### 6. Search Results Not Highlighting Matches
**Status**: 🟢 Known  
**Severity**: Low  
**Description**: Search functionality works but doesn't highlight matching text  
**Impact**: Reduced search UX  
**Enhancement**: Planned for future release

## ⚠️ Limitations

### Platform Limitations

#### Android Version Support
- **Minimum**: Android 5.0 (API 21)
- **Issue**: Some features may not work on older versions
- **Limitation**: Material Design 3 components require newer Android versions

#### iOS Support
- **Status**: Not fully tested
- **Limitation**: Firebase configuration may need iOS-specific setup
- **Recommendation**: Test thoroughly before iOS deployment

### Feature Limitations

#### Offline Functionality
- **Limitation**: Firebase sync only works when online
- **Impact**: Changes made offline sync only when connectivity restored
- **Workaround**: Use airplane mode toggle to force sync retry

#### Data Import/Export
- **Limitation**: No bulk data import from other apps
- **Impact**: Users cannot migrate from other grocery apps easily
- **Future Enhancement**: CSV import/export planned

#### Multi-User Support
- **Limitation**: No sharing lists between family members
- **Impact**: Each user has separate grocery lists
- **Future Enhancement**: Shared lists planned for v0.4.0

#### Barcode Scanning
- **Status**: Not implemented
- **Limitation**: Must manually type item names
- **Future Enhancement**: Camera integration planned

## 🔧 Performance Issues

### Database Performance
- **Issue**: Slow queries on large datasets (1000+ items)
- **Impact**: App lag when loading grocery lists
- **Optimization**: Database indexing improvements needed

### Memory Usage
- **Issue**: High memory usage with large shopping history
- **Impact**: Potential crashes on low-memory devices
- **Mitigation**: Implement data pagination

### Network Usage
- **Issue**: Inefficient Firebase queries
- **Impact**: Higher data usage than necessary
- **Optimization**: Implement query optimization

## 🎨 UI/UX Issues

### Visual Inconsistencies
- Some screens don't follow Material Design 3 guidelines consistently
- Icon sizes vary across different sections
- Color scheme not fully optimized for accessibility

### Accessibility
- Missing semantic labels on some interactive elements
- Insufficient color contrast in some theme combinations
- No support for larger text sizes

### Navigation
- Back button behavior inconsistent in some nested screens
- Deep linking not implemented
- No breadcrumb navigation for complex flows

## 📱 Device-Specific Issues

### Samsung Devices
- **Issue**: OneUI specific styling conflicts
- **Workaround**: Test on Samsung devices before release

### Pixel Devices
- **Issue**: Material You theming conflicts
- **Status**: Under investigation

### Tablets
- **Issue**: Layout not optimized for tablet screens
- **Impact**: Wasted screen space on larger displays
- **Future**: Responsive design improvements planned

## 🌐 Network Issues

### Poor Connectivity Handling
- App doesn't gracefully handle intermittent connectivity
- No proper retry mechanisms for failed requests
- Missing offline indicators in some screens

### Firebase Quotas
- May hit Firebase free tier limits with heavy usage
- No monitoring for quota usage
- Need upgrade plan for production

## 🔒 Security Considerations

### Data Security
- User data stored locally without encryption
- Firebase rules could be more restrictive
- No audit logging for data changes

### Authentication
- Password reset flow could be improved
- No multi-factor authentication
- Session management could be more robust

## 🧪 Testing Gaps

### Automated Testing
- Limited unit test coverage (~30%)
- No integration tests for critical flows
- E2E testing not implemented

### Manual Testing
- iOS testing insufficient
- Accessibility testing not comprehensive
- Performance testing on low-end devices needed

## 📋 Workarounds

### For Developers

#### Build Issues
```bash
# If imports fail, use original structure
cd lib/
# Ensure files are in Data/, Screens/, Reusable/ folders
```

#### Provider Issues
```dart
// Add proper error handling in provider initialization
try {
  await provider.initialize();
} catch (e) {
  print('Provider init failed: $e');
  // Fallback to default state
}
```

### For Users

#### Data Not Syncing
1. Check internet connectivity
2. Go to Settings → Sync Data manually
3. Restart app if issues persist

#### App Performance Issues
1. Restart the app
2. Clear app cache (Android Settings)
3. Ensure device has sufficient storage

## 📊 Issue Tracking

### Priority Levels
- 🔴 **High**: Blocks core functionality
- 🟡 **Medium**: Affects user experience
- 🟢 **Low**: Minor inconvenience

### Status Indicators
- **Active**: Currently affecting users
- **Investigating**: Under active investigation
- **Known**: Documented but not yet prioritized
- **Fixed**: Resolved in latest version

## 📞 Reporting New Issues

When reporting issues, please include:

1. **Device Information**
   - Device model and OS version
   - App version number
   - Flutter version (for developers)

2. **Steps to Reproduce**
   - Detailed steps to trigger the issue
   - Expected vs actual behavior
   - Screenshots/videos if applicable

3. **Environment Details**
   - Network connectivity status
   - App settings configuration
   - Data volume (approximate number of items)

## 🔮 Planned Fixes

### v0.3.1 (Next Patch)
- Fix import path issues
- Improve provider initialization
- Address memory leaks

### v0.4.0 (Next Minor)
- Implement responsive design
- Add comprehensive testing
- Performance optimizations
- Accessibility improvements

### v1.0.0 (Major Release)
- Multi-user support
- Barcode scanning
- Advanced analytics
- Production-ready security

---

*This document is updated regularly. Check back for the latest status on known issues.*

**Last Updated**: July 7, 2025  
**Next Review**: July 14, 2025
