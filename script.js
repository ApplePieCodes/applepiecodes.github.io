document.addEventListener("DOMContentLoaded", function() {
    const videosGrid = document.getElementById('videos-grid');

    // Replace 'metadata_urls.txt' with the actual URL of your file containing metadata URLs
    fetch('https://applepiecodes.github.io/videos/videolist.txt')
        .then(response => response.text())
        .then(text => {
            // Split the text by line breaks to get individual URLs
            const urls = text.trim().split('\n');
            
            // Fetch each metadata file
            Promise.all(urls.map(url => fetch(url)))
                .then(responses => Promise.all(responses.map(response => response.json())))
                .then(data => {
                    // Iterate over each video's metadata
                    data.forEach(video => {
                        const videoElement = document.createElement('div');
                        videoElement.classList.add('video');

                        const thumbnailElement = document.createElement('img');
                        thumbnailElement.src = video.thumbnail;
                        thumbnailElement.alt = video.title + ' Thumbnail';
                        videoElement.appendChild(thumbnailElement);

                        const titleElement = document.createElement('h2');
                        titleElement.textContent = video.title;
                        videoElement.appendChild(titleElement);

                        const authorElement = document.createElement('p');
                        authorElement.textContent = 'Author: ' + video.author;
                        videoElement.appendChild(authorElement);

                        const datePostedElement = document.createElement('p');
                        const datePosted = new Date(video.date_posted);
                        const timeElapsed = getTimeElapsed(datePosted);
                        datePostedElement.textContent = 'Posted ' + timeElapsed + ' ago';
                        videoElement.appendChild(datePostedElement);

                        videosGrid.appendChild(videoElement);
                    });
                })
                .catch(error => console.error('Error fetching metadata:', error));
        })
        .catch(error => console.error('Error fetching metadata URLs:', error));
});

function getTimeElapsed(date) {
    const now = new Date();
    const timeDifference = now - date;
    const minuteInMs = 1000 * 60;
    const hourInMs = minuteInMs * 60;
    const dayInMs = hourInMs * 24;
    const monthInMs = dayInMs * 30; // Approximation
    const yearInMs = dayInMs * 365; // Approximation

    if (timeDifference < hourInMs) {
        return Math.floor(timeDifference / minuteInMs) + ' minutes';
    } else if (timeDifference < dayInMs) {
        return Math.floor(timeDifference / hourInMs) + ' hours';
    } else if (timeDifference < monthInMs) {
        return Math.floor(timeDifference / dayInMs) + ' days';
    } else if (timeDifference < yearInMs) {
        return Math.floor(timeDifference / monthInMs) + ' months';
    } else {
        return Math.floor(timeDifference / yearInMs) + ' years';
    }
}
