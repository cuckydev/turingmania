#include <stdio.h>
#include <string.h>
#include <ctype.h>

int main(int argc, char *argv[])
{
	//Check args
	if (argc < 3)
	{
		printf("usage: mapconv in.osu out.map\n");
		return 0;
	}
	
	//Open osu file
	FILE *fp = fopen(argv[1], "r");
	if (fp == NULL)
	{
		printf("Failed to open %s\n", argv[1]);
		return 1;
	}
	
	//Open output file
	FILE *out = fopen(argv[2], "wb");
	if (out == NULL)
	{
		printf("Failed to open %s\n", argv[2]);
		return 1;
	}
	
	//Read line by line
	static char line[1024];
	while (fgets(line, sizeof(line), fp) != NULL)
	{
		//Read data
		int x, y, time, type, hitsound;
		if (sscanf(line, "%d,%d,%d,%d,%d", &x, &y, &time, &type, &hitsound) != 5)
		{
			printf("fail\n");
			break;
		}
		switch (x)
		{
			case 64:
				x = 0;
				break;
			case 192:
				x = 1;
				break;
			case 320:
				x = 2;
				break;
			case 448:
				x = 3;
				break;
			default:
				printf("Invalid X, may be a 7K song?\n");
				fclose(fp);
				fclose(out);
				return 1;
		}
		if (type & 0x80)
		{
			fwrite(&x, 1, 1, out);
			fwrite(&time, 4, 1, out);
			
			int timeend;
			if (sscanf(line, "%d,%d,%d,%d,%d,%d", &x, &y, &time, &type, &hitsound, &timeend) != 6)
			{
				printf("fail\n");
				break;
			}
			fwrite(&timeend, 4, 1, out);
		}
		else
		{
			fwrite(&x, 1, 1, out);
			fwrite(&time, 4, 1, out);
			fwrite(&time, 4, 1, out);
		}
	}
	
	fclose(fp);
	fclose(out);
	
	return 0;
}