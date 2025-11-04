<?php
// Set the target directory relative to the location of this PHP script.
// Assuming your folder structure is:
// - /your-root-folder/player.html
// - /your-root-folder/save_playlist.php
// - /your-root-folder/music/json/ (will be created here if it doesn't exist)
$target_dir = './music/json/';
$target_file = $target_dir . 'playlist_metadata.json';

// Set headers for JSON response
header('Content-Type: application/json');

// Check if the request is POST and contains JSON data
if ($_SERVER['REQUEST_METHOD'] === 'POST' && strpos($_SERVER['CONTENT_TYPE'], 'application/json') !== false) {
    
    // Read the raw JSON data sent from the client
    $json_data = file_get_contents('php://input');
    
    // Check if the directory exists, and create it if it doesn't
    if (!is_dir($target_dir)) {
        // The third parameter 'true' allows recursive directory creation
        // The second parameter '0755' is the permission mode
        if (!mkdir($target_dir, 0755, true)) {
            // Error creating directory
            echo json_encode([
                'success' => false, 
                'message' => 'Failed to create directory (' . $target_dir . '). Check server write permissions.'
            ]);
            exit;
        }
    }
    
    // Write the JSON data to the file
    // Using FILE_TEXT ensures that the data is written as plain text.
    if (file_put_contents($target_file, $json_data) !== false) {
        // Success
        echo json_encode([
            'success' => true, 
            'message' => 'Playlist saved successfully to ' . $target_file
        ]);
    } else {
        // Error writing file
        echo json_encode([
            'success' => false, 
            'message' => 'Failed to write file. Check file permissions for ' . $target_file
        ]);
    }

} else {
    // Invalid request method or content type
    echo json_encode([
        'success' => false, 
        'message' => 'Invalid request. Must be a JSON POST request.'
    ]);
}
?>