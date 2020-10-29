import secrets

#Create a new string with random characters
def secretWord(stringArray, word):
    if word != None:
        newWord = ''.join(secrets.choice(stringArray) for char in word)
        return newWord

#Take two words and combine them
def combineWords(firstWord, secondWord):
    return (firstWord+secondWord)