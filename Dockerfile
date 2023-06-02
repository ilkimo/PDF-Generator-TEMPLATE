FROM nanozoo/pdflatex:3.14159265--f2f4a3f

# Set the working directory
WORKDIR /usr/src/myapp

# Copy the Makefile into the container
COPY . .

# Set the command to be run when the container starts
ENTRYPOINT ["make"]
CMD ["all"]
