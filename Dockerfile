# Base image
FROM nanozoo/pdflatex:3.14159265--f2f4a3f

# Set the working directory
WORKDIR /usr/src/latex-generator

# Default USER and GROUP IDs (can be overwritten by --build-arg)
# This makes the container generate files that can be changed
# by standard Linux users.
# You can override these values by building the Docker Image with: 
# $ docker build --build-arg USER_ID=$(id -u) --build-arg GROUP_ID=$(id -g) -t your_image_name .
ARG USER_ID=1000
ARG GROUP_ID=1000

# Create a new user 'myuser' with the given UID and GID
RUN groupadd -g $GROUP_ID mygroup && \
    useradd -l -u $USER_ID -g mygroup myuser

# Switch to 'myuser'
USER myuser

# Copy only the Makefile into the container
COPY --chown=myuser:mygroup Makefile .

# Copy the example files into the container
COPY --chown=myuser:mygroup example/ /usr/src/latex-generator/example/

# Set the command to be run when the container starts
ENTRYPOINT ["make"]
CMD ["all"]

