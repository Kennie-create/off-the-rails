import React, { useState, useEffect, Fragment } from 'react'

import TagTile from './TagTile'

const TagsIndexContainer = () => {
  const [tags, setTags] = useState([])

  useEffect(() => {
    fetch("/api/v1/tags")
    .then(response => {
      if(response.ok){
        return response.json()
      } else {
        throw new Error(`${response.status} ${response.statusText}`)
      }
    })
    .then(parsedBody => {
      setTags(parsedBody.tags)
    })
    .catch(error => console.error(`Error in fetch ${error.message}`))
  }, [])

  const tagTiles = tags.map(tag => {
    return(
      <TagTile
        key={tag.id}
        tag={tag}
      />
    )
  })

  return (
    <div className="newFormCenterContainer">
      <div className="grid align-center">
        <div className="cell small-6 tagsContainer">
          <h2>Tags</h2>
          <ul>
            {tagTiles}
          </ul>
        </div>
      </div>
    </div>
  )
}

export default TagsIndexContainer
