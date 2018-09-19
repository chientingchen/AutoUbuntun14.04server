# Import the module
import subprocess, os
# Set up the echo command and direct the output to a pipe
p1 = subprocess.Popen(['mkswap', '/dev/sda3'], stdout=subprocess.PIPE)

# Run the command
output = p1.communicate()[0]
UUID = output[-37:-1]
FSTAB_TEMPLATE = 'UUID={UUID} none            swap    sw              0       0'
FSTAB_STRING = FSTAB_TEMPLATE.format(UUID=UUID)

file = open("/etc/fstab")
lines = file.readlines()
lines = lines[:-1]
lines.append(FSTAB_STRING+'\n\n')
file.close()

os.remove("/etc/fstab")

file = open("/etc/fstab","w")
file.writelines(lines)
file.close()

p1 = subprocess.Popen(['swapon', '/dev/sda3'], stdout=subprocess.PIPE)
