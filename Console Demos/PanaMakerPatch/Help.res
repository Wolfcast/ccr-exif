        ��  ��                  �  0   ��
 H E L P T E X T         0         -----------------------------------------------------------
            Panasonic Maker Note Patcher v%1:s
-----------------------------------------------------------

Usage:
%0:s JpegFile TagID NewValue [-p]

Notes:
- JpegFile can contain wildcards. If used and running on
  macOS, make sure JpegFile is wrapped in double quotes so
  that the command-line interpreter doesn't expand anything
  for the application.
- TagID can be a decimal or hexadecimal number, and must
  denote a maker note tag that already exists in the source
  file(s). To specify more than one tag, delimit IDs with
  commas (don't add spaces though).
- NewValue is the raw value as it can be represented in a
  string. For an array tag, use a comma to delimit element
  values.
- While the new number of elements for an array tag can be
  smaller than the old one, it cannot be greater.
  Similarly, when setting a string tag, the new value can
  be shorter than the old one, but it cannot be longer.
- Specify an empty string ("") to remove a tag's data.
- If -p is specified, a source file's 'date modified'
  value is preserved.

Examples:
%0:s P1000514.JPG $0033 "9999:99:99 00:00:00"
%0:s "*.jpg" $0033,$8010 "2009:11:15 09:30:00" -p
   