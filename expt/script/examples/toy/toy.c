int main(int argc , char **argv)
{
  int x = atoi(*(argv + 1));
  if (x >= 0) {
    printf("x >= 0\n");
  }
  else {
    printf("x < 0\n");
  }
}
