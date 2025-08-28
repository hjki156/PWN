# 本地构建

docker build -t ctf-pwn:latest .

# 以pwner用户身份运行
docker run -it  --rm --user pwner \
  -v $(pwd)/challenges:/home/pwner/CTF/challenges \
  ctf-pwn:latest