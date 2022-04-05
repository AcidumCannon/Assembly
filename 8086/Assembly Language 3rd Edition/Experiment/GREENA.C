/* Display green character 'a' on the center of the screen, works with tc 2.0 */
main()
{
 /* row 13, column 40 = 13*160+40*2 = 2160 = 0x0870
  'a' = 0x61
   green = 0b00000010 = 0x02
   green 'a' = 0x0261 */
 *(int far *)(0xb8000870)=0x0261;
}
