import sys

dic = {}

fp1 = open(sys.argv[1], "r")
fp2 = open(sys.argv[2], "w")

for line in fp1:
    temp = line.split(";")
    if temp[1][-6:-1] == "First":
        temp2 = temp[1].split(",")
        dic[temp2[0]] = temp[0]
    elif temp[1][-5:-1] == "Last":
        temp2 = temp[1].split(",")
        start = dic[temp2[0]]
        end = temp[0]
        for i in range(int(start, 16), int(end, 16) + 1):
            fp2.write("u" + hex(i)[2:] + "\n")
    else:
        fp2.write("u" + temp[0].lower() + "\n")

fp1.close()
fp2.close()
