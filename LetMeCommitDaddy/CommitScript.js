const { Octokit } = require('@octokit/core');

const octokit = new Octokit({
    auth: '',
});

//check if you have 10 commits today
// if not then script will randomly generate numbers on your README.md
async function makeTenCommits() {
    const owner = '';
    const repo = '';
    const filePath = 'README.md';  
    const commitMessage = 'Update README.md';  

    try {
        // Make 10 individual commits
        for (let i = 1; i <= 10; i++) {
            // Get the latest content and sha of the README.md file
            const existingContent = await octokit.request(`GET /repos/${owner}/${repo}/contents/${filePath}`);
            const decodedContent = Buffer.from(existingContent.data.content, 'base64').toString('utf-8');

            const randomNumber = Math.floor(Math.random() * 1000);
            const newContent = `${decodedContent}\n\nThis is commit number ${i} with a random number: ${randomNumber}`;

            // Update the README.md file
            const updateResponse = await octokit.request('PUT /repos/{owner}/{repo}/contents/{path}', {
                owner,
                repo,
                path: filePath,
                message: commitMessage,
                content: Buffer.from(newContent).toString('base64'),
                sha: existingContent.data.sha,
            });

            console.log(`Commit ${i} - README.md updated successfully:`, updateResponse.data);
        }

    } catch (error) {
        console.error('Error making commits:', error.message);
    }
}

// Uncomment the following line to run the makeTenCommits function
makeTenCommits();