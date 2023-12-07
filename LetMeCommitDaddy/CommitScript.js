const { Octokit } = require('@octokit/core');

const octokit = new Octokit({
    auth: 'YOURPATCODE',
});

//check if you have 10 commits today
// if not then script will randomly generate numbers on your README.md
async function checkCommitsForToday() {
    const owner = 'YOURGITHUBNAME';
    const repo = 'YOURREPONAME';
    const filePath = 'README.md';  
    const commitMessage = 'Update README.md';  

    // Get the current date in YYYY-MM-DD format
    const todayDate = new Date().toISOString().split('T')[0];

    try {
        // Get the list of commits for the repository
        const commitsResponse = await octokit.request('GET /repos/{owner}/{repo}/commits', {
            owner,
            repo,
        });

        // Check if any commits were made today
        const todayCommits = commitsResponse.data.filter(commit => {
            const commitDate = new Date(commit.commit.author.date).toISOString().split('T')[0];
            return commitDate === todayDate;
        });

        if (todayCommits.length >= 10) {
            console.log(`You have already made ${todayCommits.length} or more commit(s) today.`);
        } else {
            console.log(`You have made ${todayCommits.length} commit(s) today. Proceeding to add random commits.`);

            // Get the current content of the README.md file
            const existingContent = await octokit.request(`GET /repos/${owner}/${repo}/contents/${filePath}`);
            const content = existingContent.data.content;
            const decodedContent = Buffer.from(content, 'base64').toString('utf-8');

            // Modify the content by adding random numbers until reaching 10 commits
            let modifiedContent = decodedContent;
            for (let i = todayCommits.length; i < 10; i++) {
                const randomNumber = Math.floor(Math.random() * 1000);
                modifiedContent += `\n\nThis is a random number: ${randomNumber}`;
            }

            // Update the README.md file
            const updateResponse = await octokit.request('PUT /repos/{owner}/{repo}/contents/{path}', {
                owner,
                repo,
                path: filePath,
                message: commitMessage,
                content: Buffer.from(modifiedContent).toString('base64'),
                sha: existingContent.data.sha,
            });

            console.log('README.md updated successfully:', updateResponse.data);
        }
    } catch (error) {
        console.error('Error checking commits:', error.message);
    }
}

checkCommitsForToday();