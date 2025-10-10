# Supabase Export Report
Generated: 2025-10-09T14:53:41.819Z

## Summary
- ✅ Scenarios Exported: 1226
- ✅ Chapters Exported: 18
- ✅ Verses Exported: 100 (sample)
- ✅ Languages: 15

## Content Quality
- Scenarios with religious content: 447 (36.5%)
- **Action Required**: Transform to secular content

## Category Distribution
- Health & Wellness: 298 scenarios
- Parenting & Family: 212 scenarios
- Personal Growth: 188 scenarios
- Work & Career: 178 scenarios
- Relationships: 138 scenarios

## Next Steps

### 1. Content Transformation (REQUIRED)
```bash
# Remove ALL religious references
./scripts/transform_content.sh

# This will:
# - Remove Krishna, Gita, Arjuna, Divine, Sacred references
# - Replace with Research, Studies, Evidence-based language
# - Generate voice keywords
# - Create secular wellness content
```

### 2. Validate Transformation
```bash
# Check that no religious content remains
cat mindful_situations.json | grep -i -E "(krishna|gita|divine|sacred)" || echo "✅ Clean!"
```

### 3. Deploy to Firebase
```bash
# Import to Firebase Firestore
firebase deploy --only firestore

# Upload transformed content
node scripts/upload_to_firebase.ts
```

## Data Files Generated
- `gitawisdom_scenarios.json` - 1226 scenarios ready for transformation
- `supabase_export_complete.json` - Complete export with all data

## Supabase Connection
- URL: https://wlfwdtdtiedlcczfoslt.supabase.co
- Status: ✅ Connected
- Database: PostgreSQL 15.x
- Total Rows Exported: 1344

## Migration Timeline
1. Export complete: ✅ Done
2. Content transformation: ⏳ Next step
3. Firebase deployment: ⏳ Pending
4. Verification: ⏳ Pending

## Important Notes
- **CRITICAL**: All religious content MUST be removed
- **Secular focus**: Replace with evidence-based wellness language
- **Voice optimization**: Keywords generated automatically
- **Zero downtime**: Keep GitaWisdom running during migration

---

**Ready for transformation**: Run `./scripts/transform_content.sh`
