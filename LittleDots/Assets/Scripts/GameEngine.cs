using System.Collections;
using System.Collections.Generic;
using Unity.VisualScripting;
using UnityEngine;
using UnityEngine.UI;

public class GameEngine : MonoBehaviour
{
    enum Levels
    { 
        level1 = 0,
        level2 = 1,
        level3 = 2,
        level4 = 3
    }

    enum GameState
    { 
        Play = 0,
        End = 1
    }

    public GameObject mainUI;
    public GameObject phone;
    public GameObject splashUI;
    public GameObject levelSelectUI;
    public GameObject part1;
    public GameObject part2;
    public GameObject part3;
    public GameObject retryBtn;
    public GameObject snapBtn;
    public GameObject backBtn;
    public GameObject selectedBalloon;
    public ParticleSystem popBalloon;
    ParticleSystem popPrefab;
    public ParticleSystem captureImage;
    ParticleSystem capturePrefab;
    public Image captureFlash;
    public GameObject[] levels;
    public GameObject[] balloonsForLevel1;
    public GameObject[] numbersForLevel1;
    public GameObject[] linesForLevel1;
    public GameObject[] balloonsForLevel2;
    public GameObject[] numbersForLevel2;
    public GameObject[] linesForLevel2;
    public GameObject[] balloonsForLevel3;
    public GameObject[] numbersForLevel3;
    public GameObject[] linesForLevel3;
    public GameObject[] balloonsForLevel4;
    public GameObject[] numbersForLevel4;
    public GameObject[] linesForLevel4;
    public GameObject[] rewards;
    public GameObject[] lifeBalloons;
    public GameObject[] unlockLevels;
    public GameObject[] lockLevels;
    public Vector3 selectedPosition;
    public Sprite[] lifeSprites;

    public int gameStateIndex;
    public int currentLevelIndex;
    public int currentPoint;
    public int availablePlayIndex;

    public bool isDestroyBalloon;
    public bool isDestroyAnimation;

    // Start is called before the first frame update
    void Start()
    {
        //PlayerPrefs.SetInt("MaxLevel", 0);
        //PlayerPrefs.SetString("0", "");
        //PlayerPrefs.SetString("1", "");
        //PlayerPrefs.SetString("2", "");
        //PlayerPrefs.SetString("3", "");
        StartCoroutine(DelaySplashShow());
    }

    // Update is called once per frame
    void Update()
    {
        mainUI.transform.localScale = new Vector3(Screen.width / 2532f, Screen.height / 1170f, 1f);

        if (Input.GetMouseButtonDown(0))
        {
            // Creates a Ray from the mouse position
            Ray ray = Camera.main.ScreenPointToRay(Input.mousePosition);
            RaycastHit hit;

            if (Physics.Raycast(ray, out hit))
            {               
                if(gameStateIndex == (int)GameState.Play)
                {
                    if (hit.transform.gameObject.tag == "" + currentPoint)
                    {
                        popPrefab = Instantiate(popBalloon, hit.transform.position, Quaternion.identity);
                        popPrefab.Play();
                        StartCoroutine(DelayBallonAnimation());                        
                    }
                    else
                    {
                        lifeBalloons[3 - availablePlayIndex].GetComponent<Image>().sprite = lifeSprites[1];
                        availablePlayIndex--;
                        selectedBalloon = hit.transform.gameObject;
                        selectedPosition = hit.transform.gameObject.transform.position;
                        isDestroyBalloon = true;
                        isDestroyAnimation = true;

                        if (availablePlayIndex == 0)
                        {
                            retryBtn.SetActive(true);                            
                            gameStateIndex = (int)GameState.End;
                        }
                    }
                }                               
            }            
        }

        if (isDestroyAnimation)
        {
            if (isDestroyBalloon)
            {
                print("!!!!!!!!!!!!!!");
                selectedBalloon.transform.position = Vector3.MoveTowards(selectedBalloon.transform.position, rewards[currentLevelIndex].transform.position + new Vector3(-0.5f, 0.6f, 0), 2f * Time.deltaTime);
                selectedBalloon.transform.localScale = new Vector3(Random.Range(0.04f, 0.045f), Random.Range(0.04f, 0.045f), Random.Range(0.04f, 0.045f));
                selectedBalloon.transform.eulerAngles = new Vector3(Random.Range(50f, 90f), Random.Range(50f, 90f), Random.Range(50f, 90f));

                if (Vector3.Distance(selectedBalloon.transform.position, rewards[currentLevelIndex].transform.position + new Vector3(-0.5f, 0.6f, 0)) < 0.1f)
                {
                    isDestroyBalloon = false;
                }
            }
            else
            {
                selectedBalloon.transform.position = Vector3.MoveTowards(selectedBalloon.transform.position, rewards[currentLevelIndex].transform.position + new Vector3(3f, 2f, 0), 3f * Time.deltaTime);
                selectedBalloon.transform.localScale = new Vector3(Random.Range(0.02f, 0.04f), Random.Range(0.02f, 0.04f), Random.Range(0.02f, 0.04f));
                selectedBalloon.transform.eulerAngles = new Vector3(Random.Range(50f, 90f), Random.Range(50f, 90f), Random.Range(50f, 90f));

                if (Vector3.Distance(selectedBalloon.transform.position, rewards[currentLevelIndex].transform.position + new Vector3(3f, 2f, 0)) < 0.1f)
                {
                    selectedBalloon.gameObject.transform.position = selectedPosition;
                    selectedBalloon.transform.localScale = new Vector3(0.048f, 0.048f, 0.048f);
                    selectedBalloon.transform.eulerAngles = new Vector3(0, -90, 0);
                    isDestroyAnimation = false;
                }
            }
        }

        //if (gameStateIndex == (int)GameState.Play)
        //{
        //    switch (currentLevelIndex)
        //    {
        //        case (int)Levels.level1:
        //            {
        //                for (int i = 0; i < numbersForLevel1.Length; i++)
        //                {
        //                    numbersForLevel1[i].transform.LookAt(phone.transform);
        //                    balloonsForLevel1[i].transform.LookAt(phone.transform);
        //                }                        
        //                break;
        //            }
        //        case (int)Levels.level2:
        //            {
        //                for (int i = 0; i < numbersForLevel2.Length; i++)
        //                {
        //                    numbersForLevel2[i].transform.LookAt(phone.transform);
        //                    balloonsForLevel2[i].transform.LookAt(phone.transform);
        //                }
        //                break;
        //            }
        //        case (int)Levels.level3:
        //            {
        //                for (int i = 0; i < numbersForLevel3.Length; i++)
        //                {
        //                    numbersForLevel3[i].transform.LookAt(phone.transform);
        //                    balloonsForLevel3[i].transform.LookAt(phone.transform);
        //                }
        //                break;
        //            }
        //        case (int)Levels.level4:
        //            {
        //                for (int i = 0; i < numbersForLevel4.Length; i++)
        //                {
        //                    numbersForLevel4[i].transform.LookAt(phone.transform);
        //                    balloonsForLevel4[i].transform.LookAt(phone.transform);
        //                }
        //                break;
        //            }
        //    }
        //}            
    }

    IEnumerator DelaySplashShow()
    {
        yield return new WaitForSeconds(2f);

        splashUI.SetActive(false);
        levelSelectUI.SetActive(true);
        UnlockLevels();
    }

    IEnumerator DelayPart1Show()
    {
        yield return new WaitForSeconds(1f);

        part1.SetActive(false);
    }

    IEnumerator DelayPart2Show()
    {
        yield return new WaitForSeconds(2f);

        part2.SetActive(false);
        part3.SetActive(true);
        GameFormat();        
    }

    IEnumerator DelayFinalLineShow(int index)
    {
        yield return new WaitForSeconds(1f);

        switch (index)
        {
            case (int)Levels.level1:
                {
                    linesForLevel1[linesForLevel1.Length - 1].SetActive(true);
                    break;
                }
            case (int)Levels.level2:
                {
                    linesForLevel2[linesForLevel2.Length - 1].SetActive(true);
                    break;
                }
            case (int)Levels.level3:
                {
                    linesForLevel3[linesForLevel3.Length - 1].SetActive(true);
                    break;
                }
            case (int)Levels.level4:
                {
                    linesForLevel4[linesForLevel4.Length - 1].SetActive(true);
                    break;
                }
        }
    }

    IEnumerator DelayBallonAnimation()
    {
        switch (currentLevelIndex)
        {
            case (int)Levels.level1:
                {
                    balloonsForLevel1[currentPoint - 1].GetComponent<Animator>().enabled = true;
                   
                    break;
                }
            case (int)Levels.level2:
                {
                    balloonsForLevel2[currentPoint - 1].GetComponent<Animator>().enabled = true;

                    break;
                }
            case (int)Levels.level3:
                {
                    balloonsForLevel3[currentPoint - 1].GetComponent<Animator>().enabled = true;

                    break;
                }
            case (int)Levels.level4:
                {
                    balloonsForLevel4[currentPoint - 1].GetComponent<Animator>().enabled = true;

                    break;
                }
        }

        yield return new WaitForSeconds(0.15f);

        switch (currentLevelIndex)
        {
            case (int)Levels.level1:
                {
                    balloonsForLevel1[currentPoint - 1].SetActive(false);
                    numbersForLevel1[currentPoint - 1].SetActive(true);

                    if (currentPoint > 1)
                    {
                        linesForLevel1[currentPoint - 2].SetActive(true);
                    }

                    if (currentPoint == balloonsForLevel1.Length)
                    {
                        linesForLevel1[linesForLevel1.Length - 2].SetActive(true);
                        StartCoroutine(DelayFinalLineShow(currentLevelIndex));

                        StartCoroutine(DelayShowReward(currentLevelIndex));
                    }

                    currentPoint++;
                    break;
                }
            case (int)Levels.level2:
                {
                    balloonsForLevel2[currentPoint - 1].SetActive(false);
                    numbersForLevel2[currentPoint - 1].SetActive(true);

                    if (currentPoint > 1)
                    {
                        linesForLevel2[currentPoint - 2].SetActive(true);
                    }

                    if (currentPoint == balloonsForLevel2.Length)
                    {
                        linesForLevel2[linesForLevel2.Length - 2].SetActive(true);
                        StartCoroutine(DelayFinalLineShow(currentLevelIndex));
                        StartCoroutine(DelayShowReward(currentLevelIndex));
                    }

                    currentPoint++;
                    break;
                }
            case (int)Levels.level3:
                {
                    balloonsForLevel3[currentPoint - 1].SetActive(false);
                    numbersForLevel3[currentPoint - 1].SetActive(true);

                    if (currentPoint > 1)
                    {
                        linesForLevel3[currentPoint - 2].SetActive(true);
                    }

                    if (currentPoint == balloonsForLevel3.Length)
                    {
                        linesForLevel3[linesForLevel3.Length - 2].SetActive(true);
                        StartCoroutine(DelayFinalLineShow(currentLevelIndex));
                        StartCoroutine(DelayShowReward(currentLevelIndex));
                    }

                    currentPoint++;
                    break;
                }
            case (int)Levels.level4:
                {
                    balloonsForLevel4[currentPoint - 1].SetActive(false);
                    numbersForLevel4[currentPoint - 1].SetActive(true);

                    if (currentPoint > 1)
                    {
                        linesForLevel4[currentPoint - 2].SetActive(true);
                    }

                    if (currentPoint == balloonsForLevel4.Length)
                    {
                        linesForLevel4[linesForLevel4.Length - 2].SetActive(true);
                        StartCoroutine(DelayFinalLineShow(currentLevelIndex));
                        StartCoroutine(DelayShowReward(currentLevelIndex));
                    }

                    currentPoint++;
                    break;
                }
        }
    }

    IEnumerator DelayCapture()
    {
        yield return new WaitForSeconds(0.1f);

        captureFlash.gameObject.SetActive(true);

        yield return new WaitForSeconds(0.1f);

        snapBtn.SetActive(true);
        retryBtn.SetActive(true);
        backBtn.SetActive(true);

        for (int i = 0; i < availablePlayIndex; i++)
        {
            lifeBalloons[i].SetActive(true);
        }

        captureFlash.gameObject.SetActive(false);
    }

    public void Level1Click()
    {
        StartCoroutine(DelayPart1Show());
        StartCoroutine(DelayPart2Show());
        currentLevelIndex = (int)Levels.level1;
    }

    public void Level2Click()
    {
        StartCoroutine(DelayPart1Show());
        StartCoroutine(DelayPart2Show());
        currentLevelIndex = (int)Levels.level2;
    }

    public void Level3Click()
    {
        StartCoroutine(DelayPart1Show());
        StartCoroutine(DelayPart2Show());
        currentLevelIndex = (int)Levels.level3;
    }

    public void Level4Click()
    {
        StartCoroutine(DelayPart1Show());
        StartCoroutine(DelayPart2Show());
        currentLevelIndex = (int)Levels.level4;
    }

    public void BackClick()
    {
        levelSelectUI.transform.position = new Vector3(Screen.width/2 , Screen.height/2, 0f);
        UnlockLevels();

        for (int i = 0; i < 3; i++)
        {
            lifeBalloons[i].SetActive(true);
        }

        switch (currentLevelIndex)
        {
            case (int)Levels.level1:
                {
                    for (int i = 0; i < balloonsForLevel1.Length; i++)
                    {
                        balloonsForLevel1[i].SetActive(false);
                        numbersForLevel1[i].SetActive(false);
                        linesForLevel1[i].SetActive(false);
                        rewards[0].SetActive(false);
                    }
                    break;
                }
            case (int)Levels.level2:
                {
                    for (int i = 0; i < balloonsForLevel2.Length; i++)
                    {
                        balloonsForLevel2[i].SetActive(false);
                        numbersForLevel2[i].SetActive(false);
                        linesForLevel2[i].SetActive(false);
                        rewards[1].SetActive(false);
                    }
                    break;
                }
            case (int)Levels.level3:
                {
                    for (int i = 0; i < balloonsForLevel3.Length; i++)
                    {
                        balloonsForLevel3[i].SetActive(false);
                        numbersForLevel3[i].SetActive(false);
                        linesForLevel3[i].SetActive(false);
                        rewards[2].SetActive(false);
                    }
                    break;
                }
            case (int)Levels.level4:
                {
                    for (int i = 0; i < balloonsForLevel4.Length; i++)
                    {
                        balloonsForLevel4[i].SetActive(false);
                        numbersForLevel4[i].SetActive(false);
                        linesForLevel4[i].SetActive(false);
                        rewards[3].SetActive(false);
                    }
                    break;
                }
        }
    }

    public void UnlockLevels()
    {
        print(PlayerPrefs.GetInt("MaxLevel"));

        for (int i = 0; i < unlockLevels.Length;i++)
        {
            unlockLevels[i].SetActive(false);
            print(unlockLevels[i].GetComponentsInChildren<Image>()[1].gameObject.name);
            print(unlockLevels[i].GetComponentsInChildren<Image>()[2].gameObject.name);

            if (PlayerPrefs.GetString("" + i) == "true")
            {
                unlockLevels[i].GetComponentsInChildren<Image>()[1].enabled = false;
                unlockLevels[i].GetComponentsInChildren<Image>()[2].enabled = true;
            }
            else
            {
                unlockLevels[i].GetComponentsInChildren<Image>()[1].enabled = true;
                unlockLevels[i].GetComponentsInChildren<Image>()[2].enabled = false;
            }
        }

        for (int i = 0; i < lockLevels.Length; i++)
        {
            lockLevels[i].SetActive(true);
        }

        for (int i = 0; i <= PlayerPrefs.GetInt("MaxLevel"); i++)
        {
            if (i > 0 && i < 4)
            {
                lockLevels[i - 1].SetActive(false);
            }

            if (i < 4)
            {
                unlockLevels[i].SetActive(true);
            }            
        }
    }

    public void GameRetry()
    {
        GameFormat();
    }

    public void SnapClick()
    {
        snapBtn.SetActive(false);
        retryBtn.SetActive(false);
        backBtn.SetActive(false);

        for (int i = 0; i < lifeBalloons.Length; i++)
        {
            lifeBalloons[i].SetActive(false);
        }

        ScreenCapture.CaptureScreenshot(Application.persistentDataPath + "/" + System.DateTime.Now.Year + "-" + System.DateTime.Now.Month + "-" + System.DateTime.Now.Day + "-" + System.DateTime.Now.Hour + "-" + System.DateTime.Now.Minute + "-" + System.DateTime.Now.Second + ".png");        
        StartCoroutine(DelayCapture());
    }

    public void GameFormat()
    {
        for (int i = 0; i < levels.Length; i++)
        {
            levels[i].SetActive(false);
        }

        switch (currentLevelIndex)
        {
            case (int)Levels.level1:
                {
                    levels[0].SetActive(true);
                    //levels[0].transform.position = phone.transform.position + phone.transform.forward * 3;
                    levels[0].transform.LookAt(phone.transform);
                    break;
                }
            case (int)Levels.level2:
                {
                    levels[1].SetActive(true);
                    //levels[1].transform.position = phone.transform.position + phone.transform.forward * 3;
                    levels[1].transform.LookAt(phone.transform);
                    break;
                }
            case (int)Levels.level3:
                {
                    levels[2].SetActive(true);
                    //levels[2].transform.position = phone.transform.position + phone.transform.forward * 3;
                    levels[2].transform.LookAt(phone.transform);
                    break;
                }
            case (int)Levels.level4:
                {
                    levels[3].SetActive(true);
                    //levels[3].transform.position = phone.transform.position + phone.transform.forward * 3;
                    levels[3].transform.LookAt(phone.transform);
                    break;
                }
        }

        gameStateIndex = (int)GameState.Play;
        availablePlayIndex = 3;
        currentPoint = 1;

        for (int i = 0; i < lifeBalloons.Length; i++)
        {
            lifeBalloons[i].GetComponent<Image>().sprite = lifeSprites[0];
        }

        switch (currentLevelIndex)
        {
            case (int)Levels.level1:
                {
                    for (int i = 0; i < balloonsForLevel1.Length; i++)
                    {
                        balloonsForLevel1[i].SetActive(true);
                        numbersForLevel1[i].SetActive(false);
                        linesForLevel1[i].SetActive(false);
                        rewards[0].SetActive(false);
                    }
                    break;
                }
            case (int)Levels.level2:
                {
                    for (int i = 0; i < balloonsForLevel2.Length; i++)
                    {
                        balloonsForLevel2[i].SetActive(true);
                        numbersForLevel2[i].SetActive(false);
                        linesForLevel2[i].SetActive(false);
                        rewards[1].SetActive(false);
                    }
                    break;
                }
            case (int)Levels.level3:
                {
                    for (int i = 0; i < balloonsForLevel3.Length; i++)
                    {
                        balloonsForLevel3[i].SetActive(true);
                        numbersForLevel3[i].SetActive(false);
                        linesForLevel3[i].SetActive(false);
                        rewards[2].SetActive(false);
                    }
                    break;
                }
            case (int)Levels.level4:
                {
                    for (int i = 0; i < balloonsForLevel4.Length; i++)
                    {
                        balloonsForLevel4[i].SetActive(true);
                        numbersForLevel4[i].SetActive(false);
                        linesForLevel4[i].SetActive(false);
                        rewards[3].SetActive(false);
                    }
                    break;
                }
        }

        for (int i = 0; i < rewards.Length; i++)
        {
            rewards[i].SetActive(false);
        }

        retryBtn.SetActive(false);
        snapBtn.SetActive(false);
    }

    IEnumerator DelayShowReward(int index)
    {
        yield return new WaitForSeconds(1.5f);

        rewards[index].SetActive(true);

        switch (currentLevelIndex)
        {
            case (int)Levels.level1:
                {
                    for (int i = 0; i < balloonsForLevel1.Length; i++)
                    {
                        numbersForLevel1[i].SetActive(false);
                        linesForLevel1[i].SetActive(false);
                    }
                    break;
                }
            case (int)Levels.level2:
                {
                    for (int i = 0; i < balloonsForLevel2.Length; i++)
                    {
                        numbersForLevel2[i].SetActive(false);
                        linesForLevel2[i].SetActive(false);
                    }
                    break;
                }
            case (int)Levels.level3:
                {
                    for (int i = 0; i < balloonsForLevel3.Length; i++)
                    {
                        numbersForLevel3[i].SetActive(false);
                        linesForLevel3[i].SetActive(false);
                    }
                    break;
                }
            case (int)Levels.level4:
                {
                    for (int i = 0; i < balloonsForLevel4.Length; i++)
                    {
                        numbersForLevel4[i].SetActive(false);
                        linesForLevel4[i].SetActive(false);
                    }
                    break;
                }
        }

        gameStateIndex = (int)GameState.End;
        retryBtn.SetActive(true);
        snapBtn.SetActive(true);

        if (PlayerPrefs.GetInt("MaxLevel") <= currentLevelIndex)
        {
            PlayerPrefs.SetInt("MaxLevel", PlayerPrefs.GetInt("MaxLevel") + 1);
        }

        PlayerPrefs.SetString("" + currentLevelIndex, "true");
    }
}
